## Tech Stock Watcher   

### About

This is a simple Shiny app that tracks the stock price of 6 technology stocks. From the technical perspective, it has the following features:

- Use of `uiOutput`, `renderUI` and `passwordInput` to enable basic authentication using a secret access code.

- Use `dygraphs` and `quantmod` to get up-to-date stock price.

- Stock Price Time Series are grouped together to enable unified zooming.

- Use `shinycssloaders` to enable pretty rendering of progress spinners.

Author: Eric Do (ericdh1810@gmail.com)

### Package Used

`shiny` 1.0.5

`shinycssloaders` 0.2.0

`shinythemes` 1.1.1 

`quantmod` 0.4.12

`dygraphs` 1.1.1.4

### Screenshots: 

Access Page: 

<img src = figure/access_page.png>

Progress Spinners while loading stock prices

<img src = figure/progress_spinners.png>

Stock Prices Watcher

<img src = figure/stock_prices.png>

<br><br><br>

-----