META:
  name: AWS IAM - SecOps role
  provider: AWS
  category: CONFIG
  subcategory: Foundation
  template_id: 6a.aws_iam.3
  version: v1
  description: The SecOps role is an expansion of the ReadOnly role, allowing read only access to all components in a cloud account as well as access to some common operations a security engineering team needs

{% set role_name = params.get('role_name', 'secops-role') %}
{% set policy_name_1 = 'allow_kms_permissions_linked_secops_role' %}
{% set policy_name_2 = 'allow_secops' %}
{% set policy_name_3 = 'secops-allow-ec2-permissions' %}
{% set custom_policy_attachment_1 =  'custom_policy_attachment_1' %}
{% set custom_policy_attachment_2 =  'custom_policy_attachment_2' %}
{% set custom_policy_attachment_3 =  'custom_policy_attachment_3' %}
{% set aws_managed_policy_attachment = 'aws_managed_policy_attachment' %}
{% set trusted_account_ids = params.get('trusted_account_ids') %}

# Role
Create AWS IAM role {{role_name}}:
  META:
    name: Create AWS IAM role
    parameters:
      trusted_account_ids:
        description: "Specify the trusted account who is allowed to assume the role in the role trust policy."
        name: "Trusted Account Ids"
        uiElement: array
      role_name:
        description: "The name of the IAM role which helps identify this role."
        name: "Role name"
        uiElement: text
  aws.iam.role.present:
  - name: {{role_name}}
  - assume_role_policy_document: {"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"sts:AssumeRole","Principal":{"AWS":[{% for v in trusted_account_ids %}"{{v}}"{% if loop.last %}{% else %},{% endif %}{% endfor %}]},"Condition":{}}]}
  - tags:
    - Key: Name
      Value: {{role_name}}

# Policy
Create AWS IAM policy {{policy_name_1}}:
  META:
    name: Create AWS IAM policy - {{policy_name_1}}
    parameters:
      policy_name_1:
        description: "The name of the IAM policy."
        name: "Policy name"
        uiElement: text
  aws.iam.policy.present:
  - name: {{policy_name_1}}
  - policy_document: {"Version":"2012-10-17","Statement":[{"Sid":"","Effect":"Allow","Action":"kms:Decrypt","Resource":"*"}]}
  - tags:
    - Key: Name
      Value: {{policy_name_1}}

# Policy
Create AWS IAM policy {{policy_name_2}}:
  META:
    name: Create AWS IAM policy - {{policy_name_2}}
    parameters:
      policy_name_2:
        description: "The name of the IAM policy."
        name: "Policy name"
        uiElement: text
  aws.iam.policy.present:
  - name: {{policy_name_2}}
  - policy_document: {"Version":"2012-10-17","Statement":[{"Sid":"1","Effect":"Allow","Action":["trustedadvisor:*","support:RefreshTrustedAdvisorCheck","support:Describe*","snowball:List*","snowball:GetSnowballUsage","snowball:Describe*","sdb:DomainMetadata","mechanicalturk:List*","cur:Describe*","budgets:View*","aws-portal:View*","aws-marketplace:View*","aws-marketplace-management:view*"],"Resource":"*"}]}
  - tags:
    - Key: Name
      Value: {{policy_name_2}}

# Policy
Create AWS IAM policy {{policy_name_3}}:
  META:
    name: Create AWS IAM policy - {{policy_name_3}}
    parameters:
      policy_name_3:
        description: "The name of the IAM policy."
        name: "Policy name"
        uiElement: text
  aws.iam.policy.present:
  - name: {{policy_name_3}}
  - policy_document: {"Version":"2012-10-17","Statement":[{"Sid":"ForensicsDiskCollection","Effect":"Allow","Action":["ec2:ModifySnapshotAttribute","ec2:DescribeVolumes","ec2:DescribeSnapshots","ec2:DescribeInstances","ec2:CreateTags","ec2:CreateSnapshot","ec2:CopySnapshot"],"Resource":"*"},{"Sid":"CryptographicOperations","Effect":"Allow","Action":["kms:RevokeGrant","kms:ReEncrypt*","kms:ListGrants","kms:GenerateDataKey*","kms:Encrypt","kms:DescribeKey","kms:Decrypt","kms:CreateGrant"],"Resource":"*"}]}
  - tags:
    - Key: Name
      Value: {{policy_name_3}}

# Role Policy Attachment
Attachment policy {{custom_policy_attachment_1}} for Role {{role_name}}:
  META:
    name: Attachment for Role - {{policy_name_1}}
    parameters:
      policy_name_1:
        description: "The name of the IAM policy."
        name: "Policy name"
        uiElement: text
      role_name:
        description: "The name of the IAM role."
        name: "Role name"
        uiElement: text
  aws.iam.role_policy_attachment.present:
  - name: {{custom_policy_attachment_1}}
  - require:
    - aws.iam.role: Create AWS IAM role {{role_name}}
    - aws.iam.policy: Create AWS IAM policy {{policy_name_1}}
  - role_name: {{role_name}}
  - policy_arn: "${aws.iam.policy:Create AWS IAM policy {{policy_name_1}}:resource_id}"