\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{genealogic}[2026/04/22 v1.6]

% --- 1. Gestione Opzioni (KVOPTIONS prima di tutto) ---
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=GEN, prefix=GEN@}
\DeclareStringOption[default]{style}

% Passa le opzioni non riconosciute a book (es. 12pt, a4paper)
\DeclareDefaultOption{%
  \PassOptionsToClass{\CurrentOption}{book}%
}
\ProcessKeyvalOptions*

% --- 2. Caricamento Classe Base (INDISPENSABILE) ---
\LoadClass{book}

% --- 3. Pacchetti Core ---
\RequirePackage{etoolbox}
\RequirePackage{geometry}
\RequirePackage{xkeyval}
\RequirePackage{hyperref}

\hypersetup{hidelinks, pdfborder={0 0 0}}
\geometry{a4paper, margin=2.5cm, bindingoffset=1cm}

% --- 4. Logica delle Generazioni ---
\newcounter{gen@offset}
\setcounter{gen@offset}{0}

\newcommand{\SetStartingGeneration}[1]{%
  \setcounter{gen@offset}{#1}%
  \addtocounter{gen@offset}{-1}%
  \setcounter{chapter}{0}%
}

\renewcommand{\thechapter}{\the\numexpr\value{chapter} + \value{gen@offset}\relax}
\renewcommand{\thesection}{\thechapter.\arabic{section}}

% --- 5. Database e Acquisizione Dati ---
\makeatletter

\define@key{person}{nome}{\def\pers@nome{#1}}
\define@key{person}{padre}{\def\pers@padre{#1}}
\define@key{person}{madre}{\def\pers@madre{#1}}
\define@key{person}{nascita}{\def\pers@nascita{#1}}
\define@key{person}{morte}{\def\pers@morte{#1}}

\newcommand{\reset@pers@values}{%
  \def\pers@nome{Sconosciuto}\def\pers@padre{Non documentato}%
  \def\pers@madre{Non documentata}\def\pers@nascita{?}\def\pers@morte{?}%
}

\newcommand{\DeclarePerson}[1]{%
  \def\current@pers@label{#1}%
  \@ifnextchar[{\DeclarePerson@withKeys}{\DeclarePerson@noKeys}%
}

\def\DeclarePerson@withKeys[#1]#2{%
  \reset@pers@values
  \setkeys{person}{#1}%
  \DeclarePerson@Finalize{#2}%
}

\def\DeclarePerson@noKeys#1{%
  \reset@pers@values
  \DeclarePerson@Finalize{#1}%
}

\newcommand{\GetName}[1]{\ifcsdef{persname@#1}{\csuse{persname@#1}}{??}}
\newcommand{\GetLinkName}[1]{\ifcsdef{persname@#1}{\hyperref[pers:#1]{\csuse{persname@#1}}}{??}}

% --- 6. Rendering Delegato allo Stile ---
\newcommand{\DeclarePerson@Finalize}[1]{%
  \csxdef{persname@\current@pers@label}{\pers@nome}%
  % Questi comandi devono essere definiti nel file .sty
  \PrintPersonTitle{\thesection}{\pers@nome}%
  \label{pers:\current@pers@label}%
  \PrintPersonData{\pers@padre}{\pers@madre}{\pers@nascita}{\pers@morte}%
  \vspace{1ex}%
  \noindent #1\par\bigskip
}

\newcommand{\Generation}{\PrintGenerationTitle{\thechapter}}

% --- 7. Caricamento File di Stile ---
\InputIfFileExists{genealogicstyle\GEN@style.sty}{}{%
  \ClassWarning{genealogic}{Stile 'genealogicstyle\GEN@style.sty' non trovato!}
}

\makeatother