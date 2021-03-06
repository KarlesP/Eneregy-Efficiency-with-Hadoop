Energy Efficiency with Big Data (Hadoop and R)
=============================
####Some outdated information because of the new releases of the SW components####

This project is an endeavour to provide a proof of concept for using Big Data along with advanced analytics techniques to solve issues for improving energy efficiency. In this project we used some sample data sets provided by "Technical Research Centre of Finland - VTT". These data sets were collected using specialized metering devices installed by VTT in a group of buildings. For sake of of anonymity the names and locations of the buildings are replaced by hypothetical labels. Following is a list of energy effeciency use cases that were considered as part of this proof of concept. The implementation procedures of higlighted use cases in list below are explained. The details of other use cases will be coming very soon on this page.

1. Calculating the base load of the building to identify non user consumption of buildings.
2. **_Classifying the buildings on the basis of the energy efficiency and analyse the seasonal shifts in this classification._** 
3. Predicting daily energy consumption of various household devices on the basis of previous consumption pattern.
4. Collecting Twitter data for energy related topics using keyword filtering. 
</font> 
Following is the list of tools used for Big Data, advanced analytics and results visualization.

* Apache Hadoop
* Apache Pig 
* Apache Flume
* Apache Hive
* Apache oozie
* Cloudera Impala
* MongoDB (Optional)
* R Programming for Statistical Computing
* Weka 
* Tableau Public 

We used Cloudera CDH4 for Apache Hadoop, Pig, Hive, Flume, Ozzie and Cloudera Imapala.

## Software Architecture

![alt tag](https://github.com/KarlesP/Energy-Efficiency-with-Big-Data/blob/master/images/iplatform.png)

##Implementation
###Cloudera CDH4
For this proof of concept or any demo use Cloudera CDH4 quick virtual machine can be used that is available via [Cloudera official website for Quick VM ](http://www.cloudera.com/content/support/en/downloads/quickstart_vms/cdh-4-7-x.html).

For using the concept presented in this proof concept in a production environment, We recommend that you install Cloudera CDH 4.0 in pseudo distributed single node or multi node modes. We found this very helpful step by step instruction of installing CDH4 published by AVINASH KUMAR SINGH [Step by step guide for installing and configuring CDH4](https://docs.google.com/file/d/0Bx6N95pJhrROblJiaEJ0dHpwVmc/edit). Detailed cloudera documentation are official via their official documentation pages,[Ways to install CDH4](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Installation-Guide/cdh4ig_topic_4_2.html).


###  Using Apache Pig and R scripts to classify buildings on basis of energy effeciency

Following steps can be used to analyze the data for given use cases. These steps can be used with CDH4 in any configuration. We have tested it using Cloudera CDH4 quick VM. 

1. Download material in this reposiroty using following command. (Git installation is a pre-requisite)

`git clone https://github.com/KarlesP/Energy-Efficiency-with-Big-Data`

2. Extract and copy the data to HDFS

`cd Energy-Efficiency-with-Big-Data`

`unzip data.zip`

`hadoop fs -copyFromLocal hld_masked.csv .`
The above command will copy the data file with hourly consumption data to HDFS in user's home hdfs directory.

To view if the file is copied correctly, use following command
`hadoop fs -ls`

3. Using the Apache Pig script to pre-process data

`hadoop fs -ls`
 
`pig -f energy_consumption_matrix.pig`

`hadoop fs -copyToLocal energy_consumption_matrix ` .

`cd energy_consumption_matrix`

`mv part-r-00000 ../energy_consumption_matrix.csv`

File "energy_consumption_matrix.csv" can then be used as input file for R script "K-means_clustering_pig_to_R.R" for applying K-means clustering. This script needs another input file "hld_addresses_area.csv" with Real estate data of the building to calculate energy effeciency i.e. by dividing each hourly consumption value per building per month by ground floor area. 

4. Now you can use R within centos of Cloudera virtual machine however in our case we use Rstudio in Windows7 environment. It is a user preference. We preffered Windows enviroment because of the next step to use Tableau to visualize the data. In any case open R or Rstudio and set current working directory to the git folder where K-means_clustering_pig_to_R.R script is available and type following command.

 `source("K-means_clustering_pig_to_R.R")`

During execution of script you will be prompted twice to select input files. On first prompt please select "energy_consumption_matrix.csv" and on second prompt select "hld_addresses_area.csv". After the execution of script an output .txt file "energy_classes" with appended timestap in format "%Y-%j-%H%M%S" e.g. "energy_classes2014-274-224603" should be available in current working directory.

The output file should have following columns 

"building" - Building Lablel masking the building name and address.

"area" - Ground Floor Area of the building in metere squares.

"month"  - Name of the month 

"elec_Wh_per_m2" - Electricity , energy effeciency in watt hours per meter square.

"heat_Wh_per_m2" - Electricity used for heating , energy effeciency in watt hours per meter square

"cluster"  - Assigned cluster number by K-means algorithms. Please note that we are using predefined K value of 4 because we wanted to classify buildings into four groups i.e. corresponding to low, Average low, Average High, and High effeciency.

The output graph should look like this

![alt tag](https://github.com/KarlesP/Energy-Efficiency-with-Big-Data/blob/master/images/K-means.bmp)

Each point in the scatter plot represented by a hollow circle shows ennergy effeciency of a building in a particular month (January to November 2013). The size of the circle represents the size of the building while the color of the circle represents the respective cluster / class in terms of energy effeciency. The change in behaviour of the building within an year can be explained well by introducing some interactivity to this graph.

To create interactive graph we can use software like Tableau.

### Interactive Visualization of the results with Tableau Public 

1. Open Tableau public and click open data. Select the data output file from last step ofprevious section i.e. <energy_classes%Y-%j-%H%M%S.txt> file.
2. We used Tableau Public v8.2. It is capable of identifying the field separator itself but in case of some old version you may need to give "\t" or tab as a field seperator.
3. Then press go to worksheet.
4. In the worksheet. Ensure that month and building values are in Dimension list on left hand side panel. While rest of the values should be in Mesaure list.
5. Drag and drop elec_wh_per_m2 to Columns, while heat_Wh_per_m2 to Rows in the graph area.
6. Size and color on basis of assigned K-means cluster values.
7. Put filters of your choice like in our case we used months and buildings as filters to see the beahviour of building in each month.
8. Build a dashboards and thats it.
