META:
  name: Create ReadOnly role
  provider: AWS
  category: CONFIG
  description: The ReadOnly role allows read only access to all components in a cloud account

{% set role_name = params.get('role_name', 'ReadOnly') %}
{% set policy_name_1 = 'allow_kms_permissions_linked_readonly_role' %}
{% set policy_name_2 = 'VMW_saving_plan_allow' %}
{% set custom_policy_attachment_1 =  'custom_policy_attachment_1' %}
{% set custom_policy_attachment_2 =  'custom_policy_attachment_2' %}
{% set aws_managed_policy_attachment = 'aws_managed_policy_attachment' %}
{% set assume_role_account_id = params.get('assume_role_account_id') %}
{% set management_account_id = params.get('management_account_id') %}

# Role
{{role_name}}:
  META:
    name: Create AWS IAM Role
    parameters:
      assume_role_account_id:
        description: "Specify the trusted account who is allowed to assume the role in the role trust policy."
        name: "Assume role account Id"
        uiElement: text
      role_name:
        description: "The name of the IAM role which helps identify this role."
        name: "Role name"
        uiElement: text
  aws.iam.role.present:
  - name: {{role_name}}
  - assume_role_policy_document: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"sts:AssumeRole\",\"Principal\":{\"AWS\":\"{{assume_role_account_id}}\"},\"Condition\":{}}]}"
  - tags:
    - Key: Name
      Value: {{role_name}}