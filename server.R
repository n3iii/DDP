library(ggplot2)
source('tradeFunc.R')

#note shinyapps.io account is call sign.

shinyServer(function(input, output) {
        
        stockDF = reactive({
                read.csv(file = paste('./data/', input$ticker, '.csv', sep=''))
        })
        
        priceDF = reactive({
                getRange(input$sRow, input$dRange, stockDF())
        })
        
        movingSl = reactive({
                getMovingStats(input$sRow,input$dRange,input$mRange,stockDF())
        })
        
        
        output$close_text = renderText({

                paste('This tab shows the closing average for the ', input$ticker, ' stock over a
                range of ', input$dRange, ' days.')
                
        })
        output$close_plot = renderPlot({
                
                ggplot(priceDF(), aes(x=days, y=Close)) +
                        geom_line() +
                        labs(x='Days', y='Price') +
                        ggtitle(paste('Price Close for',input$ticker)) + 
                        scale_x_reverse()
                
        })
        output$slope_plot = renderPlot({
                
                slope = sd(movingSl()$cSlope)*input$sdCoef
                ggplot(movingSl(),aes(x=days,y=cSlope)) +
                        geom_line() +
                        labs(x='Days', y='Slope') +
                        ggtitle(paste(as.character(input$mRange),'Day Moving Average for',input$ticker)) + 
                        geom_hline(yintercept=0) +
                        geom_hline(yintercept=slope, color='yellow') +
                        geom_hline(yintercept=-slope, color='pink') +
                        scale_x_reverse()
        })
        output$slope_close_plot = renderPlot({
                
                slope = sd(movingSl()$cSlope)*input$sdCoef
                avg = mean(priceDF()$Close)
                trendUp = na.omit(movingSl()[movingSl()$cSlope >= slope,]$days)
                trendDown = na.omit(movingSl()[movingSl()$cSlope <= -slope,]$days)
                ggplot(priceDF(), aes(x=days, y=Close)) +
                        geom_line() +
                        labs(x='Days', y='Price') +
                        ggtitle(paste(as.character(input$mRange),'Day Trend for',input$ticker)) + 
                        geom_vline(xintercept=trendUp, color='yellow') +
                        geom_vline(xintercept=trendDown, color='pink') +
                        scale_x_reverse()
                
        })
        
        output$gain_table = renderTable({
                slope = sd(movingSl()$cSlope)*input$sdCoef
                avg = mean(priceDF()$Close)
                upVec = calcGain(priceDF(),movingSl()$cSlope>=slope,TRUE)
                downVec = calcGain(priceDF(),movingSl()$cSlope<=-slope,TRUE)
                
                if (input$gain == 'sub') {
                        totGain = upVec[1]-downVec[1]
                } else {
                        totGain = upVec[1]+downVec[1]
                }
                
                xtabVal = c(upVec[1],upVec[2],upVec[1]/upVec[2],
                            downVec[1],downVec[2],downVec[1]/downVec[2],
                            totGain,upVec[2]+downVec[2],
                            totGain/(upVec[2]+downVec[2]),
                            avg,slope)
                
                xtabLab = c('Up Slope Gain',
                            'Up Slope Trades',
                            'Up Slope Gain/Trade',
                            'Down Slope Gain',
                            'Down Slope Trades',
                            'Down Slope Gain/Trade',
                            'Total Slope Gain',
                            'Total Slope Trades',
                            'Total Slope Gain/Trade',
                            'Mean of Price Close',
                            'Standard Deviation of Slope')
                
                data.frame(Labels=xtabLab,values=xtabVal)
                
        })
        output$downloadPDF <- downloadHandler(
                filename = function() { paste(input$ticker, 'slope.pdf', sep='') },
                content = function(file) {
                        ticker=input$ticker
                        sRow=input$sRow
                        dRange=input$dRange
                        mRange=input$mRange
                        pList=list(ticker=ticker,sRow=sRow,dRange=dRange,mRange=mRange)
                        out = rmarkdown::render('movingSlope.Rmd', params=pList)
                        file.rename(out, file) # move pdf to file for downloading
                },
                contentType = 'application/pdf'
        )
        output$downloadDoc <- downloadHandler(
                filename = function() { paste(input$ticker, 'slope.doc', sep='') },
                content = function(file) {
                        ticker=input$ticker
                        sRow=input$sRow
                        dRange=input$dRange
                        mRange=input$mRange
                        pList=list(ticker=ticker,sRow=sRow,dRange=dRange,mRange=mRange)
                        out = rmarkdown::render('movingSlope.Rmd', params=pList,output_format='word_document')
                        file.rename(out, file) # move pdf to file for downloading
                },
                contentType = 'application/doc'
        )
        
})
