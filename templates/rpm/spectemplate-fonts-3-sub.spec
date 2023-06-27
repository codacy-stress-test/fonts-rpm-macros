# SPDX-License-Identifier: MIT
%dnl Packaging template: packaging fonts, released as part of something else
%dnl
%dnl This template documents spec declarations, used when packaging one or several
%dnl font families from a source rpm which is not named after the first packaged
%dnl font family:
%dnl – either because the project name differs from the main font family name
%dnl – or when the source archive and rpm are used to package more than fonts.
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

%global common_description %{expand:
}

%dnl When the SRPM headers are not provided by subpackages, License
%dnl needs to be set
License:   
%dnl Usually appropriate for a fonts-only source package (SRPM)
BuildArch: noarch

%dnl Source package (SRPM) declarations
%global    source_name    
%global    source_summary 
%dnl You can add SRPM specific text bellow %{?common_description}, that won’t
%dnl appear in font subpackages
%global    source_description %{expand:
%{?common_description}
}

%global foundry           
%global fontlicenses      OFL.txt
%global fontlicensesex    
%global fontdocs          *.txt
%global fontdocsex        %{fontlicenses}

%global fontfamily0       
%global fontsummary0      
%global fonts0            *.otf
%global fontconfs0        %{_sourcedir}/[number0]-%{fontname0}.conf
%global fontdescription0  %{expand: %{?common_description}
}

%global fontfamily1       
%global fontsummary1      
%global fonts1            
%global fontconfs1        %{_sourcedir}/[number1]-%{fontname1}.conf
%global fontdescription1  %{expand: %{?common_description}
}
%dnl
%dnl Continue as necessary…

%fontpkg
%fontmetapkg
%docpkg

%sourcelist

[number0]-%{fontname0}.conf
[number1]-%{fontname1}.conf

%patchlist


%prep
%setup
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
