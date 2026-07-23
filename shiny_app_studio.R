library(shiny)
library(shinychat)
library(bslib)
library(callr)

source("shiny_app_builder.R")

# initial greeting messages with suggestions
messages <-
  '
  ### **Hello!** What are you building today? 🚀

  Welcome to **Shiny App Studio**. Build advanced Shiny apps with natural language.

  Here are a couple of suggestions to get started:

  * <span class="suggestion submit">🌋 Build a Shiny app for the Old Faithful Geyser dataset with adjustable bins and interactive plot</span>
  * <span class="suggestion submit">📊 Build a Shiny app that performs K-means clustering on the Iris dataset with dynamic cluster selections</span>
  * <span class="suggestion submit">📈 Build a Shiny app for tracking stock prices with date range inputs and interactive charts</span>
  '

# modern styling
ui <- bslib::page_navbar(
  theme = bslib::bs_theme(
    version = 5,
    preset = "shiny",
    primary = "#6366F1",      # Modern Indigo
    secondary = "#EC4899",    # Bright Pink
    base_font = bslib::font_google("Outfit"),
    heading_font = bslib::font_google("Outfit")
  ),
  
  title = tags$div(
    class = "d-flex align-items-center gap-2",
    tags$span(style = "font-size: 1.5rem; line-height: 1;", "✨"),
    tags$span("Shiny App Studio", style = "font-weight: 800; letter-spacing: -0.5px; background: linear-gradient(135deg, #6366F1 0%, #EC4899 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent;")
  ),
  
  sidebar = bslib::sidebar(
    title = tags$div(
      style = "font-weight: 700; color: var(--bs-primary); margin-bottom: 0.5rem;",
      "Controls & Info"
    ),
    width = 320,
    
    # # toggle card for dark/light mode
    # tags$div(
    #   class = "sidebar-card",
    #   tags$h6("Interface Theme", class = "sidebar-card-title"),
    #   tags$p("Switch between dark and light mode to customize your workspace aesthetics.", class = "sidebar-card-text"),
    #   bslib::input_dark_mode(id = "dark_mode_toggle")
    # ),
    
    # tags$hr(style = "opacity: 0.15;"),
    
    # about card
    tags$div(
      class = "sidebar-card",
      tags$h6("About the Assistant", class = "sidebar-card-title"),
      tags$p("Shiny App Studio is powered by Antigravity designed by Google Deepmind to assist with building advanced Shiny web applications.", class = "sidebar-card-text"),
      tags$span(class = "badge bg-indigo-soft", "Active Session")
    ),
    
    tags$hr(style = "opacity: 0.15;"),
    
    # quick suggestion controls
    tags$div(
      class = "sidebar-card",
      tags$h6("Quick Actions", class = "sidebar-card-title"),
      tags$p("Click any preset action to run it immediately in the workspace:", class = "sidebar-card-text"),
      tags$div(
        class = "d-grid gap-2",
        actionButton("btn_geyser", " 🌋 Old Faithful Geyser App", icon = icon("water"), class = "btn btn-outline-primary btn-sm text-start"),
        actionButton("btn_kmeans", " 📊 Iris K-Means Clustering", icon = icon("chart-simple"), class = "btn btn-outline-primary btn-sm text-start"),
        actionButton("btn_stock", " 📈 Stock Market Tracker", icon = icon("chart-line"), class = "btn btn-outline-primary btn-sm text-start")
      )
    )
  ),
  
  # Workspace Page
  bslib::nav_panel(
    title = "Chat Workspace",
    icon = icon("comments"),
    
    tags$div(
      class = "chat-workspace-container",
      chat_ui(
        id = "chat",
        enable_cancel = TRUE,
        messages = messages
      )
    )
  ),
  
  # Advanced Head styling/customization
  header = tags$head(
    tags$style(HTML("
      /* Custom CSS Variables & Aesthetics */
      :root {
        --app-gradient-light: linear-gradient(135deg, #f5f7fa 0%, #e2e8f0 100%);
        --app-gradient-dark: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
        --glass-bg-light: rgba(255, 255, 255, 0.65);
        --glass-bg-dark: rgba(30, 41, 59, 0.6);
        --glass-border-light: rgba(203, 213, 225, 0.4);
        --glass-border-dark: rgba(255, 255, 255, 0.08);
        --text-color-light: #1e293b;
        --text-color-dark: #f8fafc;
      }
      
      html, body {
        height: 100%;
        margin: 0;
        font-family: 'Outfit', sans-serif !important;
        transition: background-color 0.4s ease, color 0.4s ease;
      }
      
      body.bootstrap-dark-mode {
        background: var(--app-gradient-dark) !important;
        color: var(--text-color-dark) !important;
      }
      
      body:not(.bootstrap-dark-mode) {
        background: var(--app-gradient-light) !important;
        color: var(--text-color-light) !important;
      }
      
      /* Navigation Bar styling */
      .navbar {
        backdrop-filter: blur(12px) !important;
        -webkit-backdrop-filter: blur(12px) !important;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
        transition: background-color 0.4s ease, border-color 0.4s ease;
      }
      
      body.bootstrap-dark-mode .navbar {
        background-color: rgba(15, 23, 42, 0.8) !important;
        border-bottom: 1px solid var(--glass-border-dark) !important;
      }
      
      body:not(.bootstrap-dark-mode) .navbar {
        background-color: rgba(255, 255, 255, 0.8) !important;
        border-bottom: 1px solid var(--glass-border-light) !important;
      }
      
      /* Sidebar layout */
      .sidebar {
        backdrop-filter: blur(12px) !important;
        -webkit-backdrop-filter: blur(12px) !important;
        transition: background-color 0.4s ease, border-color 0.4s ease;
      }
      
      body.bootstrap-dark-mode .sidebar {
        background-color: rgba(15, 23, 42, 0.4) !important;
        border-right: 1px solid var(--glass-border-dark) !important;
      }
      
      body:not(.bootstrap-dark-mode) .sidebar {
        background-color: rgba(248, 250, 252, 0.4) !important;
        border-right: 1px solid var(--glass-border-light) !important;
      }
      
      /* Sidebar Cards styling */
      .sidebar-card {
        background: rgba(255, 255, 255, 0.45);
        border-radius: 14px;
        padding: 16px;
        border: 1px solid var(--glass-border-light);
        transition: transform 0.2s ease, box-shadow 0.2s ease, background-color 0.4s ease;
      }
      
      body.bootstrap-dark-mode .sidebar-card {
        background: rgba(30, 41, 59, 0.4);
        border: 1px solid var(--glass-border-dark);
      }
      
      .sidebar-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.03);
      }
      
      body.bootstrap-dark-mode .sidebar-card:hover {
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
      }
      
      .sidebar-card-title {
        font-weight: 700;
        margin-bottom: 6px;
        letter-spacing: -0.1px;
      }
      
      .sidebar-card-text {
        font-size: 0.8rem;
        opacity: 0.75;
        margin-bottom: 12px;
        line-height: 1.45;
      }
      
      .bg-indigo-soft {
        background-color: rgba(99, 102, 241, 0.12);
        color: #6366F1;
        font-weight: 600;
        padding: 6px 12px;
        border-radius: 8px;
        font-size: 0.75rem;
      }
      
      body.bootstrap-dark-mode .bg-indigo-soft {
        background-color: rgba(129, 140, 248, 0.18);
        color: #818cf8;
      }
      
      /* Chat Container Layout & Glassmorphism */
      .chat-workspace-container {
        display: flex;
        justify-content: center;
        align-items: center;
        height: calc(100vh - 120px);
        width: 100%;
        padding: 10px;
      }
      
      shiny-chat-container {
        border-radius: 24px !important;
        border: 1px solid var(--glass-border-light) !important;
        backdrop-filter: blur(25px) !important;
        -webkit-backdrop-filter: blur(25px) !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.05) !important;
        transition: background-color 0.4s ease, border-color 0.4s ease, box-shadow 0.4s ease !important;
        background-color: var(--glass-bg-light) !important;
        max-width: 820px !important;
        width: 100% !important;
        height: 100% !important;
        padding: 24px !important;
      }
      
      body.bootstrap-dark-mode shiny-chat-container {
        background-color: var(--glass-bg-dark) !important;
        border: 1px solid var(--glass-border-dark) !important;
        box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25) !important;
      }
      
      /* Scrollbar styling */
      shiny-chat-messages {
        padding-right: 8px;
      }
      
      shiny-chat-messages::-webkit-scrollbar {
        width: 6px;
      }
      
      shiny-chat-messages::-webkit-scrollbar-track {
        background: transparent;
      }
      
      shiny-chat-messages::-webkit-scrollbar-thumb {
        background: rgba(99, 102, 241, 0.15);
        border-radius: 10px;
      }
      
      body.bootstrap-dark-mode shiny-chat-messages::-webkit-scrollbar-thumb {
        background: rgba(99, 102, 241, 0.3);
      }
      
      shiny-chat-messages::-webkit-scrollbar-thumb:hover {
        background: rgba(99, 102, 241, 0.45);
      }
      
      /* User Chat Bubble - Custom Gradient & Glow */
      shiny-chat-message[data-role=user], shiny-user-message {
        border-radius: 20px 20px 4px 20px !important;
        background: linear-gradient(135deg, #6366F1 0%, #4F46E5 100%) !important;
        color: white !important;
        padding: 12px 18px !important;
        box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.25) !important;
        margin-left: 20%;
        animation: messageSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
      }
      
      /* Assistant Message Animations */
      shiny-chat-message[data-role=assistant] {
        animation: messageSlideIn 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
      }
      
      shiny-chat-message .message-icon {
        background-color: white !important;
        border: 1px solid var(--glass-border-light) !important;
        box-shadow: 0 4px 10px rgba(0,0,0,0.02) !important;
        transition: transform 0.2s ease;
      }
      
      body.bootstrap-dark-mode shiny-chat-message .message-icon {
        background-color: #1e293b !important;
        border: 1px solid var(--glass-border-dark) !important;
      }
      
      shiny-chat-message:hover .message-icon {
        transform: scale(1.05);
      }
      
      @keyframes messageSlideIn {
        from {
          opacity: 0;
          transform: translateY(12px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      /* Custom Suggestion Spans */
      shiny-chat-container .suggestion {
        display: inline-flex;
        align-items: center;
        background: rgba(99, 102, 241, 0.07) !important;
        border: 1px solid rgba(99, 102, 241, 0.15) !important;
        color: #4f46e5 !important;
        text-decoration: none !important;
        padding: 8px 16px !important;
        border-radius: 30px !important;
        font-size: 0.82rem !important;
        font-weight: 600 !important;
        margin: 6px 4px !important;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
      }
      
      body.bootstrap-dark-mode shiny-chat-container .suggestion {
        background: rgba(129, 140, 248, 0.12) !important;
        border: 1px solid rgba(129, 140, 248, 0.25) !important;
        color: #a5b4fc !important;
      }
      
      shiny-chat-container .suggestion:hover {
        background: #4f46e5 !important;
        color: white !important;
        border-color: #4f46e5 !important;
        transform: translateY(-1.5px) scale(1.02);
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
      }
      
      body.bootstrap-dark-mode shiny-chat-container .suggestion:hover {
        background: #6366F1 !important;
        border-color: #6366F1 !important;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
      }
      
      shiny-chat-container .suggestion:after {
        content: ' ✦' !important;
        margin-left: 6px;
        opacity: 0.75;
      }
      
      /* Chat Input Field Styling */
      shiny-chat-input textarea {
        border-radius: 20px !important;
        border: 1px solid var(--glass-border-light) !important;
        background-color: rgba(255, 255, 255, 0.7) !important;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.01) !important;
        padding: 14px 50px 14px 18px !important;
        transition: all 0.25s ease !important;
        font-size: 0.95rem;
      }
      
      body.bootstrap-dark-mode shiny-chat-input textarea {
        background-color: rgba(15, 23, 42, 0.75) !important;
        border: 1px solid var(--glass-border-dark) !important;
      }
      
      shiny-chat-input textarea:focus {
        border-color: #6366F1 !important;
        box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15) !important;
        background-color: white !important;
      }
      
      body.bootstrap-dark-mode shiny-chat-input textarea:focus {
        background-color: rgba(15, 23, 42, 0.95) !important;
        box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.25) !important;
      }
      
      /* Chat Send Button Styling */
      shiny-chat-input .shiny-chat-btn-send {
        right: 16px !important;
        bottom: 12px !important;
        background-color: #4f46e5 !important;
        color: white !important;
        border-radius: 50% !important;
        width: 34px !important;
        height: 34px !important;
        display: grid !important;
        place-items: center !important;
        box-shadow: 0 4px 10px rgba(79, 70, 229, 0.3) !important;
        transition: all 0.25s ease !important;
      }
      
      shiny-chat-input .shiny-chat-btn-send:hover:not(:disabled) {
        background-color: #6366F1 !important;
        transform: scale(1.08);
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.45) !important;
      }
      
      shiny-chat-input .shiny-chat-btn-send:disabled {
        background-color: rgba(148, 163, 184, 0.15) !important;
        color: rgba(148, 163, 184, 0.4) !important;
        box-shadow: none !important;
      }
      
      
      /* Global Custom Scrollbars */
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }
      
      ::-webkit-scrollbar-track {
        background: transparent;
      }
      
      ::-webkit-scrollbar-thumb {
        background: rgba(148, 163, 184, 0.3);
        border-radius: 10px;
      }
      
      ::-webkit-scrollbar-thumb:hover {
        background: rgba(148, 163, 184, 0.5);
      }

      /* Animated Loader Styling */
      .agent-building-wrapper {
        margin: 12px 0;
        display: flex;
        justify-content: flex-start;
        animation: loaderSlideIn 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
      }
      
      .agent-building-wrapper.fade-out {
        animation: loaderFadeOut 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
      }
      
      .agent-loader-card {
        display: inline-flex;
        align-items: center;
        gap: 14px;
        padding: 12px 20px;
        background: rgba(99, 102, 241, 0.08);
        border: 1px solid rgba(99, 102, 241, 0.25);
        border-radius: 20px;
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        box-shadow: 0 8px 24px -6px rgba(99, 102, 241, 0.15);
        position: relative;
        overflow: hidden;
      }
      
      body.bootstrap-dark-mode .agent-loader-card {
        background: rgba(30, 41, 59, 0.6);
        border: 1px solid rgba(129, 140, 248, 0.3);
        box-shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.3);
      }
      
      .agent-loader-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 200%;
        height: 100%;
        background: linear-gradient(
          90deg,
          transparent 0%,
          rgba(255, 255, 255, 0.18) 50%,
          transparent 100%
        );
        animation: loaderShimmer 2.5s infinite;
      }
      
      .agent-loader-icon-wrapper {
        position: relative;
        width: 32px;
        height: 32px;
        display: grid;
        place-items: center;
      }
      
      .agent-loader-pulse {
        position: absolute;
        width: 100%;
        height: 100%;
        border-radius: 50%;
        background: linear-gradient(135deg, #6366F1, #EC4899);
        opacity: 0.35;
        animation: pulseGlow 1.8s infinite cubic-bezier(0.4, 0, 0.6, 1);
      }
      
      .agent-loader-sparkle {
        font-size: 1.25rem;
        z-index: 1;
        animation: sparkleRotate 2s infinite ease-in-out;
      }
      
      .agent-loader-text-wrapper {
        display: flex;
        flex-direction: column;
      }
      
      .agent-loader-title {
        font-weight: 700;
        font-size: 0.92rem;
        letter-spacing: -0.2px;
        background: linear-gradient(135deg, #4F46E5 0%, #EC4899 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        display: flex;
        align-items: center;
      }
      
      body.bootstrap-dark-mode .agent-loader-title {
        background: linear-gradient(135deg, #818CF8 0%, #F472B6 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }
      
      .agent-loader-dots span {
        display: inline-block;
        opacity: 0.2;
        font-weight: 800;
        font-size: 1rem;
        color: #6366F1;
        animation: dotWave 1.4s infinite ease-in-out;
      }
      
      body.bootstrap-dark-mode .agent-loader-dots span {
        color: #818CF8;
      }
      
      .agent-loader-dots span:nth-child(1) { animation-delay: 0s; }
      .agent-loader-dots span:nth-child(2) { animation-delay: 0.2s; }
      .agent-loader-dots span:nth-child(3) { animation-delay: 0.4s; }
      
      .agent-loader-subtitle {
        font-size: 0.73rem;
        opacity: 0.65;
        font-weight: 500;
        margin-top: 1px;
      }

      /* Hide empty placeholder message bubbles while building */
      shiny-chat-message[data-role=assistant][content=''],
      shiny-chat-message[data-role=assistant]:empty {
        display: none !important;
      }
      
      @keyframes loaderSlideIn {
        from { opacity: 0; transform: translateY(10px) scale(0.96); }
        to { opacity: 1; transform: translateY(0) scale(1); }
      }
      
      @keyframes loaderFadeOut {
        from { opacity: 1; transform: translateY(0) scale(1); }
        to { opacity: 0; transform: translateY(-6px) scale(0.96); }
      }
      
      @keyframes pulseGlow {
        0%, 100% { transform: scale(0.85); opacity: 0.25; }
        50% { transform: scale(1.35); opacity: 0.7; }
      }
      
      @keyframes sparkleRotate {
        0%, 100% { transform: scale(1) rotate(0deg); }
        50% { transform: scale(1.15) rotate(15deg); }
      }
      
      @keyframes dotWave {
        0%, 100% { opacity: 0.2; transform: translateY(0); }
        50% { opacity: 1; transform: translateY(-2px); }
      }
      
      @keyframes loaderShimmer {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(100%); }
      }
    ")),
    tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function() {
        var isBuilding = false;

        function showAgentLoader() {
          isBuilding = true;

          var chatMessages = document.querySelector('shiny-chat-messages');
          if (!chatMessages) return;
          
          if (document.getElementById('agent-building-loader')) return;
          
          var loader = document.createElement('div');
          loader.id = 'agent-building-loader';
          loader.className = 'agent-building-wrapper';
          loader.innerHTML = '<div class=\"agent-loader-card\"><div class=\"agent-loader-icon-wrapper\"><div class=\"agent-loader-pulse\"></div><span class=\"agent-loader-sparkle\">✨</span></div><div class=\"agent-loader-text-wrapper\"><div class=\"agent-loader-title\">Agent is building<span class=\"agent-loader-dots\"><span>.</span><span> .</span><span> .</span></span></div><div class=\"agent-loader-subtitle\">Generating code & Shiny UI components</div></div></div>';
          
          chatMessages.appendChild(loader);
          chatMessages.scrollTop = chatMessages.scrollHeight;
        }
        
        function removeDotsFromElement(root) {
          if (!root) return;
          try {
            var dots = root.querySelectorAll('svg.markdown-stream-dot, .markdown-stream-dot');
            dots.forEach(function(dot) {
              if (dot && dot.parentNode) dot.parentNode.removeChild(dot);
            });
            var markdownStreams = root.querySelectorAll('shiny-markdown-stream');
            markdownStreams.forEach(function(stream) {
              stream.streaming = false;
              stream.removeAttribute('streaming');
            });
            var allEls = root.querySelectorAll('*');
            allEls.forEach(function(el) {
              if (el.shadowRoot) {
                removeDotsFromElement(el.shadowRoot);
              }
            });
          } catch(err) {
            console.warn('Error removing dots:', err);
          }
        }

        function stopAllLoaders() {
          isBuilding = false;

          // 1. Remove CSS agent loader
          var loaders = document.querySelectorAll('#agent-building-loader, .agent-building-wrapper');
          loaders.forEach(function(loader) {
            loader.classList.add('fade-out');
            setTimeout(function() {
              if (loader && loader.parentNode) {
                loader.parentNode.removeChild(loader);
              }
            }, 150);
          });
          
          // 2. Clean up Shinychat loader / empty assistant message bubbles
          var chatMessages = document.querySelector('shiny-chat-messages');
          if (chatMessages) {
            var assistantMsgs = chatMessages.querySelectorAll('shiny-chat-message[data-role=\"assistant\"], shiny-chat-message[role=\"assistant\"]');
            assistantMsgs.forEach(function(msg) {
              msg.removeAttribute('streaming');
              var contentVal = msg.getAttribute('content') || msg.textContent || '';
              if (contentVal.trim().length === 0) {
                msg.remove();
              }
            });
          }
          
          // 3. Stop and remove default Shinychat three dots loader across DOM & shadow DOMs
          removeDotsFromElement(document);

          // 4. Re-enable input if disabled
          var chatInput = document.querySelector('shiny-chat-input');
          if (chatInput) {
            chatInput.disabled = false;
            chatInput.removeAttribute('disabled');
            var textarea = chatInput.querySelector('textarea');
            if (textarea) textarea.disabled = false;
          }
        }
        
        // Backward compatibility & global access
        window.removeAgentLoader = stopAllLoaders;
        window.showAgentLoader = showAgentLoader;
        
        // Register custom Shiny message handler
        function registerShinyHandler() {
          if (window.Shiny && window.Shiny.addCustomMessageHandler) {
            window.Shiny.addCustomMessageHandler('show_loader', function(message) {
              showAgentLoader();
            });
            window.Shiny.addCustomMessageHandler('stop_loaders', function(message) {
              stopAllLoaders();
            });
          } else {
            setTimeout(registerShinyHandler, 200);
          }
        }
        registerShinyHandler();

        // Listen to Shiny idle event if jQuery/Shiny exists
        if (typeof $ !== 'undefined') {
          $(document).on('shiny:idle', function() {
            var chatMessages = document.querySelector('shiny-chat-messages');
            if (chatMessages && !isBuilding) {
              var hasAssistantContent = Array.from(chatMessages.querySelectorAll('shiny-chat-message[data-role=\"assistant\"], shiny-chat-message[role=\"assistant\"]'))
                .some(function(msg) { return (msg.getAttribute('content') || msg.textContent || '').trim().length > 0; });
              if (hasAssistantContent) {
                stopAllLoaders();
              }
            }
          });
        }
        
        function setupChatObserver() {
          var chatMessages = document.querySelector('shiny-chat-messages');
          if (!chatMessages) {
            setTimeout(setupChatObserver, 300);
            return;
          }
          
          var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList') {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1) {
                    var isUserMsg = node.matches && (
                      node.matches('shiny-chat-message[data-role=\"user\"]') ||
                      node.matches('shiny-chat-message[role=\"user\"]') ||
                      node.matches('shiny-user-message')
                    );
                    if (!isUserMsg && node.querySelector) {
                      isUserMsg = !!node.querySelector('shiny-chat-message[data-role=\"user\"], shiny-chat-message[role=\"user\"], shiny-user-message');
                    }
                    
                    if (isUserMsg) {
                      showAgentLoader();
                    }
                    
                    var isAssistantMsg = node.matches && (
                      node.matches('shiny-chat-message[data-role=\"assistant\"]') ||
                      node.matches('shiny-chat-message[role=\"assistant\"]')
                    );
                    if (!isAssistantMsg && node.querySelector) {
                      isAssistantMsg = !!node.querySelector('shiny-chat-message[data-role=\"assistant\"], shiny-chat-message[role=\"assistant\"]');
                    }
                    
                    if (isAssistantMsg) {
                      var content = node.getAttribute('content') || node.textContent || '';
                      if (content.trim().length > 0) {
                        stopAllLoaders();
                      }
                    }
                  }
                });
              }
              if (mutation.type === 'attributes') {
                var target = mutation.target;
                if (target.nodeType === 1) {
                  var isAssistant = target.matches && (
                    target.matches('shiny-chat-message[data-role=\"assistant\"]') ||
                    target.matches('shiny-chat-message[role=\"assistant\"]')
                  );
                  if (isAssistant) {
                    var contentVal = target.getAttribute('content') || target.textContent || '';
                    if (contentVal.trim().length > 0) {
                      stopAllLoaders();
                    }
                  }
                }
              }
            });
          });
          
          observer.observe(chatMessages, { childList: true, subtree: true, attributes: true });
        }
        
        document.addEventListener('click', function(e) {
          var path = e.composedPath ? e.composedPath() : [e.target];
          
          var isTriggerElement = false;
          for (var j = 0; j < path.length; j++) {
            var el = path[j];
            if (el.classList && (el.classList.contains('btn') || el.classList.contains('suggestion') || el.classList.contains('shiny-chat-btn-send'))) {
              isTriggerElement = true;
              break;
            }
          }
          if (isTriggerElement) {
            setTimeout(showAgentLoader, 50);
          }
        }, true);
        
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Enter' && !e.shiftKey) {
            var path = e.composedPath ? e.composedPath() : [e.target];
            var inInput = false;
            for (var k = 0; k < path.length; k++) {
              var n = path[k];
              if (n.tagName && n.tagName.toLowerCase() === 'shiny-chat-input') {
                inInput = true;
                break;
              }
            }
            if (inInput) {
              setTimeout(showAgentLoader, 50);
            }
          }
        }, true);
        
        setupChatObserver();
      });
    "))
  )
)

server <- function(input, output, session) {
  # active background agent process tracker
  active_agent_proc <- reactiveVal(NULL)
  
  # helper function to start agent process in background
  start_agent_task <- function(prompt_text) {
    # kill any existing background process before starting new task
    proc <- active_agent_proc()
    if (!is.null(proc) && proc$is_alive()) {
      try(proc$kill_tree(), silent = TRUE)
    }
    
    session$sendCustomMessage("show_loader", list())
    
    # launch process using callr::r_bg
    new_proc <- callr::r_bg(
      function(p) {
        source("shiny_app_builder.R")
        antigravity_chat(p)
      },
      args = list(p = prompt_text),
      wd = getwd()
    )
    
    active_agent_proc(new_proc)
  }
  
  # observer to poll background agent process status
  observe({
    proc <- active_agent_proc()
    if (is.null(proc)) return()
    
    if (proc$is_alive()) {
      invalidateLater(200, session)
    } else {
      res <- tryCatch(proc$get_result(), error = function(e) NULL)
      active_agent_proc(NULL)
      
      if (!is.null(res) && nchar(trimws(res)) > 0) {
        chat_append("chat", res, role = "assistant")
      }
      
      session$sendCustomMessage("stop_loaders", list())
    }
  })
  
  
  # chat submit event
  observeEvent(input$chat_user_input, {
    req(input$chat_user_input)
    start_agent_task(input$chat_user_input)
  })
  
  # trigger prompt helper function for preset action buttons
  trigger_prompt <- function(prompt_text) {
    chat_append("chat", prompt_text, role = "user")
    start_agent_task(prompt_text)
  }
  
  # observes for quick action preset buttons in sidebar
  observeEvent(input$btn_geyser, {
    trigger_prompt("🌋 Build a Shiny app for the Old Faithful Geyser dataset with adjustable bins and interactive plot")
  })
  
  observeEvent(input$btn_kmeans, {
    trigger_prompt("📊 Build a Shiny app that performs K-means clustering on the Iris dataset with dynamic cluster selections")
  })
  
  observeEvent(input$btn_stock, {
    trigger_prompt("📈 Build a Shiny app for tracking stock prices with date range inputs and interactive charts")
  })
}

shinyApp(ui = ui, server = server)


