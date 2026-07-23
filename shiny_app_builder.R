library(reticulate)

reticulate::use_virtualenv("r-reticulate", required = TRUE)

antigravity_chat <- function(prompt) {
  tryCatch({
    py_main_agent = reticulate::py_run_string("
import asyncio
from google.antigravity import Agent, LocalAgentConfig, CapabilitiesConfig

async def _main(prompt):
    config = LocalAgentConfig(
        system_instructions='You are an expert R Shiny app developer. Always create a new folder for every Shiny app you build. If you are asked to analyze data, spawn a sub-agent to handle that.',
        capabilities=CapabilitiesConfig(),
    )
    async with Agent(config) as agent:
        response = await agent.chat(prompt=prompt)
        return await response.text()

def run_agent_sync(prompt):
    return asyncio.run(_main(prompt))
")
    result <- py_main_agent$run_agent_sync(prompt)
    cat(result, "\n")
    return(result)
  }, error = function(e) {
    warning("Error in antigravity_chat: ", e$message)
    return(paste0("Hello! I received your message: '", prompt, 
                  "'. However, I encountered a connection issue with the Python Antigravity SDK. Please check your credentials and environment setup. Details: ", e$message))
  })
}

# Usage
# tryCatch(
#   {
#     antigravity_chat(prompt = "Using HR_comma_sep.csv, analyze the satisfaction level and average monthly hours of each department. Display the results in two separate interactive plots using plotly. Make the satisfaction level plot a bar plot and the other a pie chart.")
#                        
#             
#                     
#   },
#   error = function(e) {
#     print(e)
#   }
# )