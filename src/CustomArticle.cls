% Copyright (C) 2022 Anton Rodomanov
%
% This file is part of the `CustomArticle` class.
%
% You may distribute and/or modify this code under the conditions
% of the LaTeX Project Public License, version 1.3c or any later version.

\ProvidesClass{CustomArticle}[2023/12/07 v0.1.1+ Custom class for articles]
\NeedsTeXFormat{LaTeX2e}

\RequirePackage{etoolbox}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define and process options.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newtoggle{CustomArticle@SimpleNumbering}
\togglefalse{CustomArticle@SimpleNumbering}

\DeclareOption{SimpleNumbering}{\toggletrue{CustomArticle@SimpleNumbering}}

\DeclareOption*{\ClassWarning{CustomArticle}{Unknown option `\CurrentOption`}}

\ProcessOptions\relax

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the base class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\LoadClass[a4paper,11pt]{article}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load required packages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{mathtools}
\RequirePackage{amsthm}
\RequirePackage{geometry}
\RequirePackage{thmtools}
\RequirePackage{thm-restate}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up page layout.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\geometry{
  left=3.3cm,
  top=3.8cm,
  textwidth=14.9cm,
  textheight=22cm
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define commands for setting up information about the paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------------------------------------------------------------------
% General information.
% ------------------------------------------------------------------------------

\define@key{PaperInfo}{title}{\newcommand{\PaperInfo@Title}{#1}}
\define@key{PaperInfo}{date}{\newcommand{\PaperInfo@Date}{#1}}
\define@key{PaperInfo}{version}{\newcommand{\PaperInfo@Version}{#1}}

\newcommand{\PaperGeneralInfo}[1]{\setkeys{PaperInfo}{#1}}

% ------------------------------------------------------------------------------
% Abstract, keywords, etc.
% ------------------------------------------------------------------------------

\newcommand{\PaperAbstract}[1]{\newcommand{\PaperInfo@Abstract}{#1}}
\newcommand{\PaperKeywords}[1]{\newcommand{\PaperInfo@Keywords}{#1}}
\newcommand{\PaperThanks}[1]{\newcommand{\PaperInfo@Thanks}{#1}}

% ------------------------------------------------------------------------------
% Adding authors.
% ------------------------------------------------------------------------------

\newcounter{PaperAuthor}

\define@key{PaperAuthor}{name}{
  \csdef{Author{\thePaperAuthor}@name}{#1}
}
\define@key{PaperAuthor}{affiliation}{
  \csdef{Author{\thePaperAuthor}@affiliation}{#1}
}
\define@key{PaperAuthor}{email}{
  \csdef{Author{\thePaperAuthor}@email}{#1}
}

\newcommand{\AddPaperAuthor}[1]{
  \stepcounter{PaperAuthor}
  \setkeys{PaperAuthor}{#1}

  \ifcsundef{Author{\thePaperAuthor}@name}{
    \ClassError{CustomArticle}{Name of author \thePaperAuthor\space is not specified}{}
  }{}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up title and abstract.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------------------------------------------------------------------
% Set up title.
% ------------------------------------------------------------------------------

\newcommand{\SetUpTitle}{
  \ifundef{\PaperInfo@Title}{
    \ClassError{CustomArticle}{Paper title is not specified}{}
  }{}

  \title{
    \PaperInfo@Title%
    \ifdef{\PaperInfo@Thanks}{%
      \thanks{\PaperInfo@Thanks}
    }{}
  }
}

% ------------------------------------------------------------------------------
% Set up author.
% ------------------------------------------------------------------------------

\newcounter{AuthorIndex}

\newcommand{\SetUpAuthor}{
  \def\AuthorString{}

  \setcounter{AuthorIndex}{1}
  \whileboolexpr{test{\ifnumless{\value{AuthorIndex}}{\value{PaperAuthor} + 1}}}{
    \eappto{\AuthorString}{%
      \csuse{Author{\theAuthorIndex}@name}%
      \ifboolexpe{
        test{\ifcsdef{Author{\theAuthorIndex}@affiliation}}
        or
        test{\ifcsdef{Author{\theAuthorIndex}@email}}
      }{%
        \noexpand\thanks{%
          \ifcsdef{Author{\theAuthorIndex}@affiliation}{%
            \csuse{Author{\theAuthorIndex}@affiliation}.\space%
          }{}%
          \ifcsdef{Author{\theAuthorIndex}@email}{%
            E-mail: \csuse{Author{\theAuthorIndex}@email}.%
          }{}%
        }%
      }{}%
    }
    \ifnumless{\value{AuthorIndex}}{\value{PaperAuthor}}{
      \appto{\AuthorString}{\and}
    }{}%
    \stepcounter{AuthorIndex}
  }

  \author{\AuthorString}
}

% ------------------------------------------------------------------------------
% Set up date.
% ------------------------------------------------------------------------------

\newcommand{\SetUpDate}{
  % If the paper date was not explicitly specified by the user, use the
  % date when the document was compiled.
  \ifundef{\PaperInfo@Date}{
    \newcommand{\PaperInfo@Date}{\today}
  }{}

  \date{%
    % Remove redundant vertical space if no authors were specified.
    \ifdefvoid{\AuthorString}{\vspace{-2em}}{}%
    \PaperInfo@Date%
    \ifdef{\PaperInfo@Version}{%
      \\[1ex]%
      [version \PaperInfo@Version]%
    }{}%
  }
}

% ------------------------------------------------------------------------------
% Print title and abstract.
% ------------------------------------------------------------------------------

\newcommand{\PrintTitleAndAbstract}{
  \SetUpTitle
  \SetUpAuthor
  \SetUpDate

  \maketitle

  \ifdef{\PaperInfo@Abstract}{%
    \begin{abstract}%
      \PaperInfo@Abstract%
    \end{abstract}%
  }{}

  \ifdef{\PaperInfo@Keywords}{%
    \noindent{{\small\textbf{Keywords:} \PaperInfo@Keywords}}%
  }{}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up numbering.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\nottoggle{CustomArticle@SimpleNumbering}{
% Number everything by section.
  \AtEndPreamble{
    \numberwithin{equation}{section}
    \numberwithin{table}{section}
    \numberwithin{figure}{section}

    \ifltxcounter{algorithm}{
      % This class does not load any algorithm package on its own, so set up the
      % numbering for algorithms only if some algorithm package has been loaded
      % afterwards.
      \numberwithin{algorithm}{section}
    }{}
  }
}{}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define theorem-like environments.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defer using `\newtheorem` until the end of preamble in order to avoid a
% possible conflict with the `cleveref` package in case the user loads it
% somewhere in the middle of preamble.
% See: https://tex.stackexchange.com/a/19106.
\AtEndPreamble{
% Use the same counter for all theorem-like environments.
  \nottoggle{CustomArticle@SimpleNumbering}{
    \declaretheorem[numberwithin=section]{theorem}
  }{
    \declaretheorem{theorem}
  }
  \newtheorem{lemma}[theorem]{Lemma}
  \newtheorem{proposition}[theorem]{Proposition}
  \newtheorem{corollary}[theorem]{Corollary}
  \newtheorem{assumption}[theorem]{Assumption}
  \theoremstyle{definition}
  \newtheorem{definition}[theorem]{Definition}
  \theoremstyle{remark}
  \newtheorem{remark}[theorem]{Remark}
  \newtheorem{example}[theorem]{Example}

  % If needed, tell `cleveref` the names it doesn't know by default.
  \@ifpackageloaded{cleveref}{
    \if@cref@capitalise
      \crefname{assumption}{Assumption}{Assumptions}
    \else
      \crefname{assumption}{assumption}{assumptions}
    \fi
  }{}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\endinput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%