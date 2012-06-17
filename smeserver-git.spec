%define name smeserver-git
%define version 1.0.0
%define release 2
Summary: smeserver-git provides integration for centralised git respositories on an smeserver
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
Distribution: SME Server
License: GNU GPL version 2
URL: http://www.through-ip.com
Group: SMEserver/addon
Source: smeserver-git-1.0.0.tar.gz
Packager: Marco Hess <marco.hess@through-ip.com>
BuildArchitectures: noarch
BuildRoot: /var/tmp/%{name}-%{version}
BuildRequires: e-smith-devtools
Requires: e-smith-release >= 8.0
Requires: git
AutoReqProv: no

%description
smeserver-git enables centralised git repositories on an SME server and enables 
access to these repositories through HTTP/HTTPS. Repositories are created and
managed through a server-manager panel that also configures the access permissions
to the repositories based on the existing SME users and groups. The package
installes and enables a virtual server 'git' on the current host like in
git.host.com. Repositories are then available as https://git.host.com/gitrepo.git.

%changelog
* Sun Jun 17 2012 Jonathan Martens <smeserver-contribs@snetram.nl> 1.0.0-2
- Rip out gitweb and create tgz file

* Sun Apr 29 2012 Marco Hess <marco.hess@through-ip.com> 1.0.0-1
- initial release

%prep
%setup

%build
perl createlinks

%install
rm -rf $RPM_BUILD_ROOT
(cd root   ; find . -depth -print | cpio -dump $RPM_BUILD_ROOT)
rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT > %{name}-%{version}-filelist

%clean
rm -rf $RPM_BUILD_ROOT

%files -f %{name}-%{version}-filelist
%defattr(-,root,root)
