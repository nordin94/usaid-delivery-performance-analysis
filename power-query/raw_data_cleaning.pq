// Power Query (M) used in excel/USAID_Delivery_Analysis.xlsx to clean data/raw/Raw_Data.csv.
// Change the file path in the Origen step to where you saved the repo.
// Step names are in Spanish because they come from a Spanish-language Excel.

section Section1;

shared Raw_Data = let
    Origen = Csv.Document(File.Contents("C:\path\to\repo\data\raw\Raw_Data.csv"),[Delimiter=",", Columns=35, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Encabezados promovidos",{{"Ã¯Â»Â¿ID", "ID"}}),
    #"Columnas quitadas" = Table.RemoveColumns(#"Columnas con nombre cambiado",{"Load_Date", "Source_System"}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Columnas quitadas","CÃ#(0083)Â´te d'Ivoire","Côte d'Ivoire",Replacer.ReplaceText,{"Country"}),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Valor reemplazado","N/A","Unknown",Replacer.ReplaceText,{"Shipment Mode"}),
    #"Tipo cambiado con configuración regional" = Table.TransformColumnTypes(#"Valor reemplazado1", {{"Unit of Measure (Per Pack)", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional1" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional", {{"Line Item Quantity", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional2" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional1", {{"Line Item Value", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional3" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional2", {{"Pack Price", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional4" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional3", {{"Unit Price", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional5" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional4", {{"Scheduled Delivery Date", type date}}, "en-US"),
    #"Tipo cambiado con configuración regional6" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional5", {{"Delivered to Client Date", type date}}, "en-US"),
    #"Tipo cambiado con configuración regional7" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional6", {{"Delivery Recorded Date", type date}}, "en-US"),
    #"Personalizada agregada" = Table.AddColumn(#"Tipo cambiado con configuración regional7", "Freight status", each if [#"Freight Cost (USD)"] = "Freight Included in Commodity Cost" then "Included in commodity"
else if [#"Freight Cost (USD)"] = "Invoiced Separately" then "Invoiced separately"
else if Text.StartsWith([#"Freight Cost (USD)"], "See") then "Shared with another shipment"
else "Charged"),
    #"Personalizada agregada1" = Table.AddColumn(#"Personalizada agregada", "Freight USD", each if [Freight status] = "Charged" then Number.From([#"Freight Cost (USD)"], "en-US") else null),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Personalizada agregada1",{{"Freight USD", type number}}),
    #"Tipo cambiado con configuración regional8" = Table.TransformColumnTypes(#"Tipo cambiado", {{"Freight USD", type number}}, "en-US"),
    #"Tipo cambiado con configuración regional9" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional8", {{"Line Item Insurance (USD)", type number}}, "en-US"),
    #"Personalizada agregada2" = Table.AddColumn(#"Tipo cambiado con configuración regional9", "Weight status", each if [#"Weight (Kilograms)"] = "Weight Captured Separately" then "Captured separately"
else if Text.StartsWith([#"Weight (Kilograms)"], "See") then "Shared with another shipment"
else "Recorded"),
    #"Personalizada agregada3" = Table.AddColumn(#"Personalizada agregada2", "Weight kg", each if [Weight status] = "Recorded" then Number.From([#"Weight (Kilograms)"], "en-US") else null),
    #"Tipo cambiado con configuración regional10" = Table.TransformColumnTypes(#"Personalizada agregada3", {{"Weight kg", type number}}, "en-US"),
    #"Personalizada agregada4" = Table.AddColumn(#"Tipo cambiado con configuración regional10", "Days late", each Duration.Days([Delivered to Client Date] - [Scheduled Delivery Date])),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Personalizada agregada4",{{"Days late", Int64.Type}}),
    #"Personalizada agregada5" = Table.AddColumn(#"Tipo cambiado1", "Delivery status", each if [Days late] <= 0 then "On time" else "Late")
in
    #"Personalizada agregada5";