Introduction
------------

This package integrates git into the SME server. It features:

* Create centralised git repositories through the server-manager
* Access rights based on SME server users and groups
* Access repositories through https://git.host/repo.git
* Auto redirect from http to https for all access
* Use git.host virtual server for the git repositories
* Git repository names independent of ibays and other resources
* Viewing of repositiries through gitweb
* Support for gravatars enabled in gitweb
* Automatic markdown of README.md into README.html and shown in gitweb

Required Packages
-----------------

* git       - dag repository
* gitweb    - dag repository
* highlight - See http://www.andre-simon.de - Can be installed from the epel repositories