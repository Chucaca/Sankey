source('./r_files/flatten_HTML.r')

############### Library Declarations ###############
libraryRequireInstall("networkD3");
libraryRequireInstall("data.table")
####################################################

################### Actual code ####################
dataset <- Values
data1 <- data.table(dataset)

# create source and target location for each path
data1[order(kv_session, Date), rn := 1:.N, by = kv_session]
data1[,source := paste0(location, "_", rn)]
data1[order(rn), target := shift(source, type = "lead"), by = kv_session]

# create source and target table
source_target <- data1[!is.na(target),.(source, target)]
source_target[, value := .N, by = list(source, target)]
source_target <- unique(source_target)

# create nodes
nodes <- data.table("id" = unique(c(source_target$source, source_target$target)))
nodes[,name := sub('_[0-9]*$', '', nodes$id)]

# change source and target to position number in nodes
source_target$source <- match(source_target$source, nodes$id) - 1
source_target$target <- match(source_target$target, nodes$id) - 1



####################################################

############# Create and save widget ###############
p = sankeyNetwork(Links = source_target, Nodes = nodes, Source = 'source',
                  Target = 'target', Value = 'value', NodeID = 'name');
internalSaveWidget(p, 'out.html');
####################################################
