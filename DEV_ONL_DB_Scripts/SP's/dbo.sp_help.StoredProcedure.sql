/****** Object:  StoredProcedure [dbo].[sp_help]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_help]
AS
SELECT * from sys.synonyms;

GO
