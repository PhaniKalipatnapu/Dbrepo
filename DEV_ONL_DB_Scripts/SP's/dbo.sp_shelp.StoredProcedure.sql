/****** Object:  StoredProcedure [dbo].[sp_shelp]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc  [dbo].[sp_shelp] (@name as Varchar(255))
As
 Begin
   Declare @tableName  as Varchar(255) = '';
   Select @tableName  = B.base_object_name  from  Sys.synonyms B;
   exec master.dbo.sp_help @tableName;
 End 
 
 
GO
