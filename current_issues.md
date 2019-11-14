# Current Issues

### CFN-INIT
- Ansible is not installing through `packages > ansible`.
- CFN signal not occuring causing stack to roll back
- Temp fix : `pip install ansible` in UserData.

### Jenkins Instance
- After temp removing the cfn signal resource on instance creation policy, several issues ocuring within Jenkins server instance
- I am able to install ansible via `pip install ansible`
- When trying to run the cfn-init command again, it is able to pull down and run the playbook but one part of the playbook run fails
when trying to install all of the specified plugins. This is due to an issue with the Jenkins  Global Security `CSRF Protection`. 
Disabling this all together and re-running the playbook manually via CLI does successfully install the missing plugins.

### Jenkins Pipeline
- Web server able to deploy acceptance successfully, but faiing integration due to different expected version of Nginx. Need to install specific version or adjust spec test.

### Other Notes
- Python version is still 2.7
- Pip version is very out of date (v9.03)
- Consideration for using Amazon Linux 2 AMI? This would require modifying cfn-init to use `systemd` instead of `sysinitv`

### TODO
- Install ansible on Jenkins Server through different means.
- Change Jenkins config XML settings file to disable CSRF Protection for time being.