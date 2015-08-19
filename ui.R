
shinyUI(fluidPage(
        
        titlePanel("Stock Moving Slope"),
        
        sidebarLayout(
                sidebarPanel(
                        
                        selectInput(inputId = "ticker",
                                    label = "Stock Ticker:",
                                    choices = c('AAPL', 'IBM', 'JNJ', 'WMT', 'YUM'),
                                    selected = 'IBM'),
                        
                        sliderInput("sRow",
                                    "Row in File to Start:",
                                    min = 1,
                                    max = 500,
                                    value = 1),
                        
                        sliderInput("dRange",
                                    "Date Range:",
                                    min = 30,
                                    max = 500,
                                    value = 50),
                        
                        sliderInput("mRange",
                                    "Moving Average Range:",
                                    min = 5,
                                    max = 50,
                                    value = 20),
                        sliderInput("sdCoef",
                                    "Standard Deviation Multiplier:",
                                    min = 0.5,
                                    max = 3,
                                    value = 1),
                        radioButtons("gain", "Gain Table Action:",
                                     c("Add High/Low" = "add",
                                       "Subtract High/Low" = "sub")),
                        downloadButton('downloadPDF', 'Download PDF'),
                        downloadButton('downloadDoc', 'Download Word Doc')
                        
                ),
                
                mainPanel(
                        tabsetPanel(
                                tabPanel('Welcome',
                                         h3('Stock Moving Slope'),
                                         p('The purpose of this app is to use skills learned in this
                                           specialization to look at the stock market.  In particular, 
                                           we want to calculate a moving average of the slope of 
                                           the closing price for a selected stock.  This may help show 
                                           if a stock is trending or staying within a range.'),
                                         p('The sidebar contains the following selectors.'),
                                         tags$ul(
                                                 tags$li("Ticker the the abbreviation for the stock"), 
                                                 tags$li("Start Row, most recent day to look at"), 
                                                 tags$li("Range of Rows (days) preceding the start row."),
                                                 tags$li("Moving Average Range for the slope of the close line."),
                                                 tags$li("Standard Deviation Multiplier for the yellow/pink cutoff."),
                                                 tags$li("Gain Table Action allow you to go short on the gain table.")),
                                         p('The Closing Price Plot tab shows a plot of the closing price 
                                           for the selected stock over the range of days selected, starting from
                                           the start day selected.'),
                                         p('The Slope Plot tab is the moving average of the slope, starting
                                           with the most recent day and going back for the Moving Average Range. 
                                           It then takes the next most recent day, doing the same thing. 
                                           This continues for the selected range of days, so that the plot
                                           will show the incremental moving changes of the slope for the day
                                           range selected.'),
                                         p('The Slope/Close Plot tab overlays the closing price line with information 
                                           from the Slope Plot.  Any day the slope plot is one standard 
                                           deviation or more above zero, that day is colored in yellow.  Any 
                                           day the slope plot is one standard deviation or more below zero 
                                           is colored in pink.  The Standard Deviation Multiplier allows you to 
                                           vary the yellow/pink cutoff from 0.5 to 3 standard deviations.'),
                                         p('The Gain Table tab is a chart of what would happen if you used the 
                                           Slope/Close plot to buy (take a long position) on the first day a 
                                           stock went yellow and sell the stock on the first non-yellow day.  It 
                                           does the same for the pink, but the radio button lets you subtract 
                                           the pink from the yellow (taking a short position on the pinks).')
                                         ),
                                tabPanel("Closing Price Plot", 
                                         textOutput('close_text'), 
                                         'Notice that the days run from higher to lower values.  
                                         That is because the number represents the row in which 
                                         that data is contained.', 
                                         plotOutput("close_plot", height = "300px")
                                ),
                                tabPanel("Slope Plot", 
                                         p('The slope plot moves about zero as it goes from a positive slope
                                           to negative and back again.  The yellow line is the standard deviation 
                                           times its multiplier above zero.  The pink line shows it below zero.'),
                                         plotOutput("slope_plot", height = "300px")
                                ),
                                tabPanel("Slope/Close Plot", 
                                         p('Any day on which the moving average of the slope is equal to or
                                           greater than one standard deviation, that day has a yellow line.  
                                           Any day on which a negative slope is equal to or
                                           greater than one standard deviation, that day has a pink line.'), 
                                         plotOutput("slope_close_plot", height = "300px")
                                ),
                                tabPanel("Gain Table", 
                                         p('Although the purpose for exploring the moving average of the slope 
                                           is to determine if the stock is trending or in a range, 
                                           it is interesting to see what would happen if you used the slope ranges
                                           from the previous chart as buy and sell signals.  For a given day range 
                                           you can vary the length of the moving average, the standard deviation 
                                           cutoff and adding or subtracting the pink buys and sells.'),
                                         tableOutput("gain_table")
                                )
                )
        )
)
))        
