libs = c("dplyr", "ggplot2", "reshape2", "tools", "magrittr", "tibble", "readxl", 
         "data.table", "scales", "tidyr", "reshape2", "stringr", "tidyverse", "readxl", "corrplot", "purrr")
libsLoaded = lapply(libs,function(l){suppressWarnings(suppressMessages(library(l, character.only = TRUE)))})

#---- Color palettes ----- #

#mermaid 
hydrangea = c("#D3D5E3", "#615C7F", "#CFC3D1", "#C8BED7", "#C2A8BE", "#9D5D7C", "#C4C1A9", "#8B9488", "#899CC1", "#657FA2", 
              "#C2C0D1", "#8483AD", "#D0BAD0", "#B7AECE", "#8D779E", "#874257", "#6D7364", "#35331F", "#5C6B90", "#3A4170", 
              "#847F9C", "#888CAE", "#B38DA5", "#7B668C", "#503E5C", "#403039", "#5E604D", "#4D4935", "#405C81", "#4D4D73")

# --------- Volcano plot --------------- #
plot_volcano = function(dataframe){
    df = as.data.frame(dataframe)
    # add a column of NAs
    df$diffexpressed <- "nonSig"
    # if log2Foldchange > 0.6 and pvalue < 0.05, set as "UP" 
    df$diffexpressed[df$log2FoldChange > 0.58 & df$padj < 0.05] <- "Up-regulated"
    # if log2Foldchange < -0.6 and pvalue < 0.05, set as "DOWN"
    df$diffexpressed[df$log2FoldChange < -0.58 & df$padj < 0.05] <- "Down-regulated"
    
    ## Things to add = get rid of all points and rowa that have a -log10(padj) of 0 
    ## Add theme 
    ## Add labels
    
    plot = df %>% ggplot(aes(x = log2FoldChange, y = -log10(padj), color = diffexpressed)) + geom_point(stat = "identity", alpha = 0.5, size = 1.5) +
        theme_bw() + xlim(-2.5, 2.5) + scale_color_manual(values = c("#0B032D", "grey72", "#621940"))
    return(plot)
}

# ---------- Barplots ----------- #


plot_genes = function(DEGs){
    df= NULL
    for (i in 1:length(DEGs)){
        name = names(DEGs)[i]
        down = DEGs[[i]] %>%  as.data.frame() %>%  
            dplyr::filter(padj < 0.05 & log2FoldChange < -.58) %>% nrow()
        up <- DEGs[[i]] %>%  as.data.frame() %>% 
            dplyr::filter(padj < 0.05 & log2FoldChange > 0.58) %>% nrow()
        df = rbind(df, data.frame(name,up,down)) }
    df %<>% reshape2::melt()
    
    ## if df has intercept - DESeq2 not treated as pairwise 
    df = df[!df$name == "Intercept",]
    
    plot = df %>% ggplot(aes(x= reorder(name, -value), y = value, fill=variable)) + geom_bar(stat = "identity",   colour = "white") +
        theme_bw() + theme(axis.text.x = element_text(angle = 70,  hjust=1, face = "bold"), legend.position = "bottom", 
                           legend.title= element_blank(), axis.title.y = element_text(size = 12)) + scale_fill_manual(values = c("#E56B6F", "#0B032D"), labels=c('Upregulated', 'Downregulated')) +
        ylab("No. DEGs") + xlab("") }



# --------- Correlation plots -----------------#

correlation_scatter = function(df){
    ggplot(df, aes(x= df[1,], y = df[2,], group = colours)) + 
    geom_point(color = c("grey72"), alpha = 0.8, size = 2.5) + ylim(-5,5) + xlim(-5, 5) + 
    theme_bw() + scale_color_manual(values= c("grey72")) + xlab("UPF3A KD") +
    ylab("UPF3B KD") + theme(legend.position = "none") + geom_vline(xintercept = 0) + 
    geom_hline(yintercept = 0)}