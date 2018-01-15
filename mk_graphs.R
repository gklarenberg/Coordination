library(tidyverse)

participants <- read.csv("data/MergedParticipants.csv", stringsAsFactors = FALSE)
corrected_participants <- participants %>%
  rename(rawAffiliation = Affiliation) %>%
  mutate(Affiliation = ifelse(rawAffiliation == "Student", "Graduate", rawAffiliation))


affiliation_graph <- function(count_data, title="Participants by Affiliation"){
  # top to bottom ordering of affiliations to draw
  affiliations <- c("Undergraduate", "Graduate", "Post-Doc", "Staff", "Faculty", "Other")
  
  # Y location for text
  text_y <- max(count_data$n) * 0.66
  
  # count everyone up
  everyone <- count_data %>% tally()
  
  # count up any other affiliations...
  others <- count_data %>%
    filter(! Affiliation %in% affiliations) %>%
    tally()

  # and replace those other affiliation rows with an "Other" total
  plot_data <- count_data %>%
    filter(Affiliation %in% affiliations) %>%
    union(data.frame(Affiliation="Other", n=others$nn))

  # set bar order by re-assigning the factor levels, note reversing  
  plot_data$Affiliation = factor(plot_data$Affiliation, levels=rev(affiliations))
    
  p <- ggplot(data=plot_data, aes(x=Affiliation, y=n, fill=Affiliation)) +
    geom_bar(stat="identity") +
    coord_flip() +
    guides(fill=FALSE) +
    theme(plot.title = element_text(hjust = 0.5)) + 
    labs(y = "Number of Participants", x = "UF Affiliation", title=title) + 
    annotate("text", y=text_y, x=1.5, label=paste0("Total Participants: ", everyone$nn))
  
  return(p)
}

# All paricipants graph
affiliation_counts <- corrected_participants %>%
  group_by(Affiliation) %>%
  tally()
p <- affiliation_graph(affiliation_counts)
ggsave("graphs/participants_all.png", plot=p, height=3, width=4)
print(p)

# Most recent full year
year <- 2017
affiliation_counts <- corrected_participants %>%
  filter(Year == year) %>%
  group_by(Affiliation) %>%
  tally()
p <- affiliation_graph(affiliation_counts, paste0("Participants by Affiliation in ", year))
ggsave(paste0("graphs/participants_", year, ".png"), plot=p, height=3, width=4)