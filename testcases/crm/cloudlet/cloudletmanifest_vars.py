manifest_1 =  """manifestitems:
- id: 1
  title: Download the MobiledgeX bootstrap VM image (please use your console credentials)
    from the link
  contenttype: url
  contentsubtype: none
  content: https://artifactory-qa.mobiledgex.net/artifactory/baseimages/mobiledgex-v4.4.4.qcow2"""

manifest_2 = """- id: 2
  title: Execute the following command to upload the image to your glance store
  contenttype: command
  contentsubtype: none
  content: openstack image create mobiledgex-v4.4.4 --disk-format qcow2 --container-format
    bare --shared --file mobiledgex-v4.4.4.qcow2"""

manifest_3 = """- id: 3
  title: Download the manifest template
  contenttype: code
  contentsubtype: yaml
  content: """

manifest_3_private_key = ".*BEGIN RSA PRIVATE KEY[\s\S]{100,}END RSA PRIVATE KEY"  # key with 100+ chars
manifest_3_crm_access_key = ".*path: /root/accesskey/accesskey.pem[\s\S]*-----BEGIN PRIVATE KEY-----[\s\S]{20,}[\s\S]{100,}"
