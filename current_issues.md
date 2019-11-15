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
- Acceptance stage in pipeline usually takes \~14-16 mins long.

### Changes to Implement
- Install ansible on Jenkins Server through `pip install ansible` in UserData
- Change Jenkins config XML settings file to disable CSRF Protection for time being and pull down file into server to then replace 
Jenkins main config.xml file
- Add task in playbook.yml for copying the jenkins config.xml file to `/var/lib/jenkins/config.xml`
- Modify Jenkinsfile to remove build custom cfn_nag rules rake task
- Update cfn_nag version/new bundle install and Gemfile.lock
- Refactors igw cfn_nag rule to work with latest version. Also changed rake task for security testing ro run a `cfn_nag_scan` against all templates in a specified location.
(Previously was only running `cfn_nag` again a single template.)
- Added unit tests for cfn_nag custom rules and rake task associated with it
