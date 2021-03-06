
/*  Copyright 2015 Aalto University, Ahmed Hussnain

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.*/ 
/********************************************
*********************************************
******Apache Pig Script *********************
**for formulating energy consumption matrix**
*********************************************
*********************************************/ 

-- Loading the required jar files
REGISTER /usr/lib/pig/piggybank.jar;
-- REGISTER /home/cloudera/joda-time-2.4/joda-time-2.4.jar;
-- DEFINE CustomFormatToISO org.apache.pig.piggybank.evaluation.datetime.convert.CustomFormatToISO();
-- DEFINE ISOToUnix org.apache.pig.piggybank.evaluation.datetime.convert.ISOToUnix();

-- Removing the output directory if it already exists
rmf energy_consumption_matrix;

-- Loadin the energy consumption data
energy = LOAD 'hld_masked.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',') AS (dev:int, building:chararray, meternumb:int ,type:chararray, date:chararray,hr:int,consumption:int);

-- Removing any rows with blank building names 
NARM = FILTER energy BY (building matches 'Building.*');

-- Segregating electricity & electricity used for heating
elect = FILTER NARM BY type == 'elect';
heat = FILTER NARM BY type == 'Dist_Heating';

-- Aggregating the data to get average hourly electricity consumption per day per building.
elec_group  = GROUP elect BY (building,date);
avg_daily_elec = FOREACH elec_group GENERATE group, AVG(elect.consumption) AS avg_hourly_consumption;
avg_daily_elec_months = FOREACH avg_daily_elec GENERATE group.building,avg_hourly_consumption, GetMonth(ToDate(group.date,'yyyyMMdd')) AS month;

-- Aggregating the data to get average hourly electricity consumption per month per building
avg_monthly_elec_group = GROUP avg_daily_elec_months BY (building,month); 
avg_monthly_elec = FOREACH avg_monthly_elec_group  GENERATE group.building,group.month, AVG(avg_daily_elec_months.avg_hourly_consumption) AS avg_monthly_consumption;

-- Removing the electricity consumption values for December as only a few day data was available
monthly_elec = FILTER avg_monthly_elec BY month!=12;

-- Aggregating the data to get average hourly electricity for heating consumption per day per building.
heat_group  = GROUP heat BY (building,date);
avg_daily_heat = FOREACH heat_group GENERATE group, AVG(heat.consumption) AS avg_hourly_consumption;
avg_daily_heat_months = FOREACH avg_daily_heat GENERATE group.building,avg_hourly_consumption, GetMonth(ToDate(group.date,'yyyyMMdd')) AS month;

-- Aggregating the data to get average hourly electricity for heating consumption per month per building
avg_monthly_heat_group = GROUP avg_daily_heat_months BY (building,month); 
avg_monthly_heat = FOREACH avg_monthly_heat_group  GENERATE group.building,group.month, AVG(avg_daily_heat_months.avg_hourly_consumption) AS avg_monthly_consumption;

-- Removing the electricity consumption values for December as only a few day data was available
monthly_heat = FILTER avg_monthly_heat BY month!=12;

-- Joining the electricity and electricity consumed for heating tables to form the energy consumption matrix
main_matrix = JOIN monthly_elec BY (building,month), monthly_heat BY (building,month);
energy_comsumption_matrix = FOREACH main_matrix GENERATE $0 as building, $1 as month, $2 as elect_consumption, $5 as heat_consumption;

-- Storing the data
STORE energy_comsumption_matrix INTO 'energy_consumption_matrix' USING PigStorage(',');
