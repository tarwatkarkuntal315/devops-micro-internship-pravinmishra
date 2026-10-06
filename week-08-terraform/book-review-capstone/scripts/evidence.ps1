# Read-only AWS evidence for the Book Review capstone screenshots 07-16.
# Usage (from book-review-capstone\):  .\scripts\evidence.ps1 07
# Prints no ARNs, so the AWS account ID never appears.
param([Parameter(Mandatory = $true)][string]$Shot)

$ErrorActionPreference = 'Stop'
$R = 'ap-south-1'
$P = 'Name=tag:project,Values=book-review'

function Title($t) {
  Write-Host ''
  Write-Host 'Kuntal Tarwatkar' -ForegroundColor Green
  Write-Host "Book Review capstone | AWS $R | $t" -ForegroundColor Cyan
  Write-Host ''
}

function SgName($id) {
  aws ec2 describe-security-groups --region $R --group-ids $id --query 'SecurityGroups[0].GroupName' --output text
}

switch ($Shot) {
  '07' {
    Title 'Screenshot 07 - six subnets across two Availability Zones'
    aws ec2 describe-subnets --region $R --filters $P `
      --query 'sort_by(Subnets,&CidrBlock)[].{Name:Tags[?Key==`Name`]|[0].Value,Tier:Tags[?Key==`Tier`]|[0].Value,CIDR:CidrBlock,AZ:AvailabilityZone,AutoPublicIP:MapPublicIpOnLaunch,VPC:VpcId}' `
      --output table
  }
  '08' {
    Title 'Screenshot 08 - public / private tier separation (routing + security groups)'
    Write-Host 'Route tables (0.0.0.0/0 target per tier):' -ForegroundColor Yellow
    aws ec2 describe-route-tables --region $R --filters $P `
      --query 'RouteTables[].{RouteTable:Tags[?Key==`Name`]|[0].Value,Subnets:length(Associations[?SubnetId]),DefaultRoute:Routes[?DestinationCidrBlock==`0.0.0.0/0`]|[0].[GatewayId,NatGatewayId]|[?@]|[0] || `none (local only)`}' `
      --output table
    Write-Host 'Security group rules (Egress=False = inbound, True = outbound; admin IP masked):' -ForegroundColor Yellow
    $mask = [System.Text.RegularExpressions.MatchEvaluator] { param($m) '<admin-ip>/32'.PadRight($m.Value.Length) }
    aws ec2 describe-security-group-rules --region $R --filters $P `
      --query 'sort_by(SecurityGroupRules,&to_string(IsEgress))[].{Rule:Tags[?Key==`Name`]|[0].Value,Egress:IsEgress,Port:FromPort,FromOrTo:CidrIpv4 || ReferencedGroupInfo.GroupId}' `
      --output table | ForEach-Object { [regex]::Replace($_, '\b\d{1,3}(\.\d{1,3}){3}/32', $mask) }
  }
  '09' {
    Title 'Screenshot 09 - Web and Application compute in their subnets'
    aws ec2 describe-instances --region $R --filters $P 'Name=instance-state-name,Values=running' `
      --query 'sort_by(Reservations[].Instances[],&PrivateIpAddress)[].{Name:Tags[?Key==`Name`]|[0].Value,Type:InstanceType,AZ:Placement.AvailabilityZone,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress || `none`,State:State.Name,IMDSv2:MetadataOptions.HttpTokens}' `
      --output table
  }
  '10' {
    Title 'Screenshot 10 - public (internet-facing) load balancer'
    aws elbv2 describe-load-balancers --region $R --names book-review-public-alb `
      --query 'LoadBalancers[].{Name:LoadBalancerName,Scheme:Scheme,Type:Type,State:State.Code,AZs:join(`, `,AvailabilityZones[].ZoneName),DNS:DNSName}' `
      --output table
    aws elbv2 describe-listeners --region $R --load-balancer-arn (aws elbv2 describe-load-balancers --region $R --names book-review-public-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text) `
      --query 'Listeners[].{Listener:join(``,[Protocol,`:`,to_string(Port)]),Action:DefaultActions[0].Type}' --output table
  }
  '11' {
    Title 'Screenshot 11 - internal (private) load balancer'
    aws elbv2 describe-load-balancers --region $R --names book-review-internal-alb `
      --query 'LoadBalancers[].{Name:LoadBalancerName,Scheme:Scheme,Type:Type,State:State.Code,AZs:join(`, `,AvailabilityZones[].ZoneName),DNS:DNSName}' `
      --output table
    $dns = aws elbv2 describe-load-balancers --region $R --names book-review-internal-alb --query 'LoadBalancers[0].DNSName' --output text
    Write-Host "DNS resolves to private VPC addresses only:" -ForegroundColor Yellow
    Resolve-DnsName $dns -Type A | Select-Object Name, IPAddress | Format-Table -AutoSize
  }
  '12' {
    Title 'Screenshot 12 - healthy targets (both target groups)'
    foreach ($tg in 'book-review-web-tg', 'book-review-app-tg') {
      $arn = aws elbv2 describe-target-groups --region $R --names $tg --query 'TargetGroups[0].TargetGroupArn' --output text
      Write-Host "$tg" -ForegroundColor Yellow
      aws elbv2 describe-target-health --region $R --target-group-arn $arn `
        --query 'TargetHealthDescriptions[].{Instance:Target.Id,Port:Target.Port,Health:TargetHealth.State}' --output table
    }
  }
  '13' {
    Title 'Screenshot 13 - managed MySQL (Amazon RDS)'
    aws rds describe-db-instances --region $R `
      --query 'DBInstances[?starts_with(DBInstanceIdentifier,`book-review`)].{DB:DBInstanceIdentifier,Role:ReadReplicaSourceDBInstanceIdentifier && `Read replica` || `Primary`,Engine:join(` `,[Engine,EngineVersion]),Class:DBInstanceClass,Status:DBInstanceStatus,Encrypted:StorageEncrypted}' `
      --output table
  }
  '14' {
    Title 'Screenshot 14 - high availability (Multi-AZ primary)'
    aws rds describe-db-instances --region $R --db-instance-identifier book-review-mysql `
      --query 'DBInstances[].{DB:DBInstanceIdentifier,MultiAZ:MultiAZ,PrimaryAZ:AvailabilityZone,StandbyAZ:SecondaryAvailabilityZone,SubnetGroup:DBSubnetGroup.DBSubnetGroupName,Subnets:join(`, `,DBSubnetGroup.Subnets[].SubnetAvailabilityZone.Name)}' `
      --output table
  }
  '15' {
    Title 'Screenshot 15 - read replica'
    aws rds describe-db-instances --region $R --db-instance-identifier book-review-mysql-replica `
      --query 'DBInstances[].{Replica:DBInstanceIdentifier,Source:ReadReplicaSourceDBInstanceIdentifier,AZ:AvailabilityZone,Status:DBInstanceStatus,Public:PubliclyAccessible}' `
      --output table
    aws rds describe-db-instances --region $R --db-instance-identifier book-review-mysql `
      --query 'DBInstances[].{Primary:DBInstanceIdentifier,ReadReplicas:join(`, `,ReadReplicaDBInstanceIdentifiers)}' `
      --output table
  }
  '16' {
    Title 'Screenshot 16 - database is private, MySQL only from the Application tier'
    aws rds describe-db-instances --region $R `
      --query 'DBInstances[?starts_with(DBInstanceIdentifier,`book-review`)].{DB:DBInstanceIdentifier,PubliclyAccessible:PubliclyAccessible,SecurityGroup:VpcSecurityGroups[0].VpcSecurityGroupId}' `
      --output table
    $db = aws ec2 describe-security-groups --region $R --filters 'Name=group-name,Values=book-review-db-sg' --query 'SecurityGroups[0]' --output json | ConvertFrom-Json
    Write-Host "Inbound rules of $($db.GroupName) ($($db.GroupId)):" -ForegroundColor Yellow
    foreach ($p in $db.IpPermissions) {
      foreach ($g in $p.UserIdGroupPairs) { "  TCP $($p.FromPort) from security group $(SgName $g.GroupId) ($($g.GroupId))" }
      foreach ($c in $p.IpRanges) { "  TCP $($p.FromPort) from CIDR $($c.CidrIp)" }
    }
    $ep = aws rds describe-db-instances --region $R --db-instance-identifier book-review-mysql --query 'DBInstances[0].Endpoint.Address' --output text
    Write-Host ''
    Write-Host 'DB endpoint resolves to a private address (10.0.21.x / 10.0.22.x):' -ForegroundColor Yellow
    Resolve-DnsName $ep -Type A | Where-Object IPAddress | Select-Object IPAddress | Format-Table -AutoSize
  }
  default { Write-Host 'Usage: .\scripts\evidence.ps1 07|08|09|10|11|12|13|14|15|16' }
}
