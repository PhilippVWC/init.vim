# ======================================================
# Clientseitiges Pre-commit-R-Skript zum Speichern der
# folgenden.
# projektspezifischen Informationen vor einem
# Git-commit:
#   - Version des R-Interpreters
#   - Benutzte R-Pakete inkl. Versionen der Pakete
# und anschließendem Code-Formatieren gemaess dem
# R-Paket styleR
#------------------------------------------------------
# Voraussetzungen:
# 1.  Die .Rprofile-Datei ist im Wurzel-Verzeichnis
#     des Renv- bzw. Git-Projektes (gleiches Projekt)
#     zu hinterlegen.
# 2.  Die Variable "projectPath" muss den Pfad zum
#     Projektordner enthalten und in .Rprofile definiert
#     sein.
# 3.  Konfiguriere Dateipfad auf den sich das Skript
#     auswirken soll:
snapshotDir <- paste0(projectPath, "")
#------------------------------------------------------
# Philipp van Wickevoort Crommelin (pvwc)
# parcIT GmbH
# ======================================================
if ("cli" %in% installed.packages()[, "Package"]) {
  cli::cli_h1(paste0("Pre commit script"))
} else {
  cat("### Pre commit script ###\n")
}

# R-Paketinstallationen ueberpruefen
# Funktionsdefinition checkInstallation {{{

checkInstallation <- function(pkg, repo) {

  # Check devtools dependency first
  if (!("devtools" %in% installed.packages()[, "Package"])) {
    tryCatch(
      expr = {
        cat(paste0(
          "### Install devtools first ###\n",
          "### This is done only once ###\n"
        ))
        install.packages("devtools")
        cat("### devtools sucessfully installed ###\n")
        devtoolsIsInstalled <- TRUE
      },
      warning = function(w) {
        stop("devtools installation exited with warning")
      },
      error = function(e) {
        stop("devtools could not be installed")
      }
    )
  } else {
    devtoolsIsInstalled <- TRUE
  }

  if (!(pkg %in% installed.packages()[, "Package"])) {
    tryCatch(
      expr = {
        if ("cli" %in% installed.packages()[, "Package"]) {
          cli::cli_div(theme = list(span.green = list(color = "green")))
          cli::cli_h2(paste0(
            "Install package {.green ",
            pkg,
            "}"
          ))
          cli::cli_text(paste0("This is done only once"))
          cli::cli_end()
        } else {
          cat(paste0(
            "### Package \"",
            pkg,
            "\" will be installed ###\n"
          ))
          cat("### This is done only once ###\n")
        }
        # Installation of package
        if (repo == "cran") {
          install.packages(pkgs = pkg)
        } else {
          devtools::install_github(repo = repo)
        }
        if ("cli" %in% installed.packages()[, "Package"]) {
          cli::cli_div(theme = list(span.green = list(color = "green")))
          cli::cli_alert_success(paste0(
            "Package {.green ",
            pkg,
            "} sucessfully installed"
          ))
          cli::cli_end()
        } else {
          cat(paste0(
            "### Package \"",
            pkg,
            "\" sucessfully installed ###\n"
          ))
        }
        assign(
          x = paste0(tolower(pkg), "IsInstalled"),
          value = TRUE,
          envir = globalenv()
        )
      },
      warning = function(w) {
        stop(paste0(
          "### Installation of package \"",
          pkg,
          "\" exited with warning ###"
        ))
      },
      error = function(e) {
        stop(paste0(
          "### Installation of package \"",
          pkg,
          "\" exited with error ###"
        ))
      }
    )
  } else {
    assign(
      x = paste0(tolower(pkg), "IsInstalled"),
      value = TRUE,
      envir = globalenv()
    )
  }
}

# }}}
# Installiere Paketabhaengigkeiten falls noetig {{{
checkInstallation(
  pkg = "cli",
  repo = "cran"
)
checkInstallation(
  pkg = "renv",
  repo = "cran"
)
checkInstallation(
  pkg = "git2r",
  repo = "cran"
)
checkInstallation(
  pkg = "Rfiglet",
  repo = "wrathematics/Rfiglet"
)
checkInstallation(
  pkg = "styler",
  repo = "cran"
)
# }}}
# Hauptprogramm {{{

if (rfigletIsInstalled) {
  Rfiglet::figlet(message = basename(projectPath), font = "chunky")
}

# save private project library {{{

# Die Variable projectPath muss in der
# in der .Rprofile-Datei hinterlegt.
if (renvIsInstalled) {
  tryCatch(
    expr = {
      cli::cli_h1(paste0("Snapshot R project library"))
      {
        cli::cli_div(theme = list(span.blue = list(color = "blue")))
        cli::cli_text(paste0(
          "Consider R source code files in: ",
          "{.blue {snapshotDir}}"
        ))
        cli::cli_end()
      }
      lockfile <- paste0(projectPath, "renv.lock")
      renv::snapshot(
        project = snapshotDir,
        lockfile = lockfile,
        prompt = FALSE,
        force = TRUE
      )
    },
    warning = function(w) {
      print(w)
    },
    error = function(e) {
      print(e)
    }
  )
} else {
  cli::cli_div(theme = list(span.red = list(color = "red")))
  cli::cli_alert_info(paste0("Renv is {.red not installed}"))
  cli::cli_alert_info(paste0("Private project library could not be saved"))
  cli::cli_end()
}
# }}}
# format r scripts {{{

if (git2rIsInstalled & stylerIsInstalled) {
  cli::cli_h1(paste0("Format R scripts"))
  {
    cli::cli_div(theme = list(span.blue = list(color = "blue")))
    cli::cli_text(paste0(
      "Identify staged R source code files in: ",
      "{.blue {projectPath}}"
    ))
    cli::cli_end()
  }
  skripte <- paste0(
    projectPath,
    list.files(
      path = projectPath,
      all.files = TRUE, # Versteckte Dateien
      pattern = "^.*R$", # Nur R-Skripte suchen
      recursive = TRUE
    )
  )
  gitStagedDateien <- as.character(
    paste0(
      projectPath,
      git2r::status(repo = projectPath)$staged
    )
  )
  # Konfiguriere R-Skripte, die nicht formatiert
  # werden sollen.
  ignoriere <-
    character(0)
  #   paste0(
  #     projectPath,
  #     list.files(
  #       path = paste0(
  #         projectPath,
  #         "Marktdatenszenarien/K15_Aktien/Entwicklung/"
  #       ),
  #       all.files = TRUE, # Versteckte Dateien
  #       pattern = "^.*R$", # Nur R-Skripte suchen
  #       recursive = TRUE
  #     )
  #   )
  cli::cli_h2(paste0("Format scripts"))
  gitStagedSkripte <-
    gitStagedDateien[(gitStagedDateien %in% skripte) &
      !(gitStagedDateien %in% ignoriere)]
  styler::style_file(
    path = gitStagedSkripte,
    scope = "tokens"
  )
} else {
  cli::cli_alert_info(paste0("Scripts could not be formatted"))
}

# }}}

cli::cli_alert_success(paste0("Pre commit script successfully executed"))

# }}}
