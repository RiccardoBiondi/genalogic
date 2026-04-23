\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{genealogic}[2026/04/22 v1.0 Classe Albero Genealogico]

% --- 1. Gestione Opzioni ---
% Passa tutte le opzioni (es. 12pt, a4paper) alla classe base book
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{book}%
}
\ProcessOptions\relax

% --- 2. Caricamento Classe Base ---
\LoadClass{book}

% --- 3. Pacchetti Fondamentali ---
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage{etoolbox}
\RequirePackage{titlesec} % Per formattare i titoli
\RequirePackage{geometry}
\RequirePackage{xkeyval}
\RequirePackage{hyperref} % Fondamentale per i collegamenti ipertestuali


\hypersetup{
    hidelinks,
    pdfborder={0 0 0} % Ulteriore sicurezza per rimuovere i bordi
    %colorlinks=true,       % Colora il testo invece di fare riquadri
    %linkcolor=black,        % Colore dei link interni (come i nomi dei parenti)
    %urlcolor=cyan,         % Colore dei link web
    %pdftitle={Albero Genealogico},
}

% --- 4. Logica delle Generazioni e Offset ---
\newcounter{gen@offset}
\setcounter{gen@offset}{0}

% Comando per impostare da quale generazione parte il ramo corrente.
% Esempio: \SetStartingGeneration{2} farà sì che il primo capitolo 
% del ramo venga numerato co    me "Generazione 2".
\newcommand{\SetStartingGeneration}[1]{%
  \setcounter{gen@offset}{#1}%
  \addtocounter{gen@offset}{-1}%
  \setcounter{chapter}{0}% Reset del conteggio capitoli interno di book
}

% Ridefinizione del numero del capitolo: visualizza (Capitolo + Offset)
\renewcommand{\thechapter}{\the\numexpr\value{chapter} + \value{gen@offset}\relax}

% Ridefinizione della sezione: visualizza (Generazione.Persona)
\renewcommand{\thesection}{\thechapter.\arabic{section}}

% --- 5. Formattazione Estetica (Stile Default) ---

% Margini predefiniti
\geometry{a4paper, margin=2.5cm, bindingoffset=1cm}

% Formato del titolo della Generazione (Chapter)
\titleformat{\chapter}[display]
  {\normalfont\huge\bfseries\centering}
  {\small\textit{Livello Generazionale}}
  {1ex}
  {\titlerule\vspace{1ex}GENERAZIONE \thechapter}
  [\vspace{1ex}\titlerule]

% Formato del titolo della Persona (Section)
\titleformat{\section}
  {\normalfont\Large\bfseries}{\thesection}{1em}{}[\hrule]

% --- 6. Comandi Interfaccia Utente ---

% Comando per iniziare una nuova generazione
\newcommand{\Generation}{%
  \chapter{}% Il titolo è gestito dal format sopra, lasciamo vuoto l'argomento
}

% Comando per definire una persona
% Sintassi: \Person{label_univoca}{Nome Cognome}
\newcommand{\Person}[2]{%
  \section{#2}%
  \label{pers:#1}%
}



\makeatletter

% --- Chiavi ---
\define@key{person}{nome}{\def\pers@nome{#1}}
\define@key{person}{padre}{\def\pers@padre{#1}}
\define@key{person}{madre}{\def\pers@madre{#1}}
\define@key{person}{nascita}{\def\pers@nascita{#1}}
\define@key{person}{morte}{\def\pers@morte{#1}}

\newcommand{\reset@pers@values}{%
  \def\pers@nome{Sconosciuto}%
  \def\pers@padre{Non documentato}%
  \def\pers@madre{Non documentata}%
  \def\pers@nascita{?}%
  \def\pers@morte{?}%
}

% --- Logica di acquisizione ---
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

% --- Nuovo comando per recuperare il nome ---
% Questo comando cercherà il nome salvato tramite la label
\newcommand{\GetName}[1]{%
  \ifcsdef{persname@#1}{\csuse{persname@#1}}{??}%
}

% --- Comando per creare il link al nome ---
\newcommand{\GetLinkName}[1]{%
  \ifcsdef{persname@#1}{%
    % \hyperlink{nome_ancora}{testo_cliccabile}
    % Il nome dell'ancora creato da \label{pers:xxx} è solitamente 'pers:xxx'
    \hyperref[pers:#1]{\csuse{persname@#1}}%
  }{%
    ??% Caso in cui la label non esiste ancora
  }%
}

% --- Rendering Finale ---
\newcommand{\DeclarePerson@Finalize}[1]{%
  % SALVATAGGIO DEL NOME: Associa il nome alla label corrente
  \csxdef{persname@\current@pers@label}{\pers@nome}%
  
  \section{\pers@nome}
  \label{pers:\current@pers@label}
  
  \noindent\begin{minipage}{\textwidth}
    \small
    \begin{tabular}{ll}
      \textbf{Padre:} & \pers@padre \\
      \textbf{Madre:} & \pers@madre \\
      \textbf{Periodo:} & \pers@nascita\ -- \pers@morte \\
    \end{tabular}
  \end{minipage}
  \par\medskip
  
  \noindent #1\par\bigskip
}

\makeatother