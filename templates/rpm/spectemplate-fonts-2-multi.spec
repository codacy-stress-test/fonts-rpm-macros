# SPDX-License-Identifier: MIT
%dnl Packaging template: multi-family fonts packaging.
%dnl
%dnl This template documents spec declarations, used when packaging multiple font
%dnl families, from a single dedicated source archive. The source rpm is named
%dnl after the first (main) font family). Look up “fonts-3-sub” when the source
%dnl rpm needs to be named some other way.
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

%dnl A text block that can be reused as part of the description of each
%dnl subpackage.
%global common_description %{expand:
}

%dnl The following declarations will be aliased to [variable]0 and reused for all
%dnl generated *-fonts packages unless overriden by a specific [variable][number]
%dnl declaration.
%global foundry           
%global fontlicense       OFL
%global fontlicenses      OFL.txt
%global fontlicensesex    
%global fontdocs          *.txt
%global fontdocsex        %{fontlicenses}

%dnl Declaration for the subpackage containing the first font family. All the
%dnl [variable]0 declarations are aliased to [variable].
%global fontfamily0       
%global fontsummary0      
%global fonts0            *.otf
%global fontconfs0        %{_sourcedir}/[number0]-%{fontname0}.conf
%dnl Please add a few lines of description specific to the font family
%dnl contained in this package bellow %{?common_description}.
%global fontdescription0  %{expand: %{?common_description}
}

%dnl Declaration for the subpackage containing the second font family.
%global fontfamily1       
%global fontsummary1      
%global fonts1            
%global fontconfs1        %{_sourcedir}/[number1]-%{fontname1}.conf
%global fontdescription1  %{expand: %{?common_description}
}
%dnl
%dnl Continue as necessary…

%dnl “fontpkg” accepts the usual selection argument:
%dnl – “-z [number]” process a specific declaration block
%fontpkg
%dnl
%dnl Generate a font meta(sub)package header for all the font
%dnl subpackages generated in this spec. Optional arguments:
%dnl – “-n [name]”      use [name] as metapackage name
%dnl – “-s [variable]”  use the content of [variable] as metapackage summary
%dnl – “-d [variable]”  use the content of [variable] as metapackage description
%dnl – “-z [numbers]”   restrict metapackaging to [numbers] comma-separated list
%dnl                    of font package suffixes
%fontmetapkg
%dnl
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
