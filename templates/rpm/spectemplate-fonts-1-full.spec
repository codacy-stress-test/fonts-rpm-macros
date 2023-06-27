# SPDX-License-Identifier: MIT
%dnl Packaging template: less common patterns for single-family fonts packaging.
%dnl
%dnl This template documents less common spec declarations, used when packaging a
%dnl single font family, from a single dedicated source archive.
%dnl
%dnl It is part of the following set of packaging templates:
%dnl “fonts-0-simple”: basic single-family fonts packaging
%dnl “fonts-1-full”:   less common patterns for single-family fonts packaging
%dnl “fonts-2-multi”:  multi-family fonts packaging
%dnl “fonts-3-sub”:    packaging fonts, released as part of something else
%dnl
Version:   
Release:   
URL:       

%global foundry           
%global fontlicense       OFL
%dnl
%dnl The following declarations are lists of space-separated shell globs
%dnl   – matching files associated with the font family,
%dnl   – as they exist in the build root,
%dnl   — at the end of the %build stage:
%dnl – legal files (licensing…)
%global fontlicenses      OFL.txt
%dnl – exclusions from the %{fontlicenses} list
%global fontlicensesex    
%dnl – documentation files
%global fontdocs          *.txt
%dnl – exclusions from the %{fontdocs} list
%global fontdocsex        %{fontlicenses}

%global fontfamily0       
%global fontsummary0      
%dnl The created package name, should you need to override it
%dnl (this is usually a terrible idea).
%global fontname0         
%dnl A container for additional subpackage declarations.
%global fontheader0       %{expand:
Obsoletes: 
}
%dnl
%dnl More shell glob lists:
%dnl – font family files
%global fonts0            *.otf
%dnl – exclusions from the %{fonts0} list
%global fontsex0          
%dnl – fontconfig files
%global fontconfs0        %{_sourcedir}/[number0]-%{fontname0}.conf
%dnl – exclusions from the %{fontconfs0} list
%global fontconfsex0      
%dnl – appstream files, if any (generated automatically otherwise)
%global fontappstreams0   
%dnl – exclusions from the %{fontappstreams0} list
%global fontappstreamsex0 
%global fontdescription0  %{expand:
}

%fontpkg
%dnl
%dnl Generate a doc (sub)package header. This is useful to ship separately
%dnl bulky optional documentation such as PDF font specimens
%docpkg

%sourcelist

[number0]-%{fontname0}.conf

%patchlist

%dnl Patch declarations.
%patchlist

%prep
%setup
%dnl Convert upstream files to UTF-8 and Unix end of lines if necessary
%dnl Optional arguments:
%dnl -e [encoding] source OS encoding (auto-detected otherwise)
%dnl -n            do not recode files, only adjust folding and end of lines
%linuxtext *.txt

%build
%fontbuild

%install
%fontinstall

%check
%fontcheck

%fontfiles

%files doc
%defattr(644, root, root, 0755)
%license OFL.txt
%doc *.pdf

%changelog
