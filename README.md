# Shiny App Studio

Shiny App Studio is an R Shiny application that allows you to build advanced Shiny apps using natural language. It is powered by the Antigravity SDK and runs via the `reticulate` package to interface with Python.

## Prerequisites

Before running the application locally, ensure you have the following installed on your system:
- **R**: Ensure you have R installed (version 4.0 or higher is recommended).
- **Python**: Ensure you have Python installed, as the Antigravity SDK is a Python package.

## 1. Download the Project

Clone this repository or download the source code files to your local machine:

```bash
git clone <repository-url>
cd <repository-directory>
```

Alternatively, just ensure you have the `shiny_app_studio.R` and `shiny_app_builder.R` files in your working directory.

## 2. Install Required R Packages

Open your R console or RStudio and install the necessary R packages for the Shiny app to run:

```R
install.packages(c("shiny", "bslib", "callr", "reticulate", "remotes"))

# If shinychat is not available on CRAN, install it from GitHub:
# remotes::install_github("rstudio/shinychat")
install.packages("shinychat")
```

## 3. Set Up the Virtual Environment and Antigravity SDK

The application relies on the `google-antigravity` Python package. The app explicitly looks for a Python virtual environment named `r-reticulate` to load the SDK. We use the `reticulate` R package to create this virtual environment and install the Antigravity SDK into it.

Run the following commands in your R console:

```R
library(reticulate)

# Create a virtual environment named "r-reticulate"
virtualenv_create("r-reticulate")

# Install the Antigravity SDK into this virtual environment
virtualenv_install("r-reticulate", packages = c("google-antigravity"))
```

This ensures that the `shiny_app_builder.R` script can successfully load the environment using `reticulate::use_virtualenv("r-reticulate", required = TRUE)` and access the necessary Python modules.

## 4. Run the Application

Once the dependencies and the virtual environment are set up, you can run the Shiny App Studio locally.

In your R console, make sure your working directory is set to the folder containing the app files, then run:

```R
library(shiny)
runApp("shiny_app_studio.R")
```

Alternatively, if you are using RStudio, you can open `shiny_app_studio.R` and click the **Run App** button in the top right corner of the script editor.

## Using the App

When the application launches, you will be greeted by the Shiny App Studio interface. You can type natural language prompts to describe the Shiny app you want to build, or click one of the quick action buttons to try out a preset prompt (e.g., Old Faithful Geyser App or Iris K-Means Clustering). The background agent will generate the app code and respond in the chat workspace.
