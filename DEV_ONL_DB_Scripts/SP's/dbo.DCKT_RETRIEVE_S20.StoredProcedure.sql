/****** Object:  StoredProcedure [dbo].[DCKT_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DCKT_RETRIEVE_S20] (
 @Ac_File_ID    	CHAR(10),
 @Ac_Exists_INDC	CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DCKT_RETRIEVE_S20
  *     DESCRIPTION       : Checks whether the File ID exists in the Dockets_T1 table.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE @Lc_No_TEXT	CHAR(1)	= 'N',
		  @Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM DCKT_Y1 D
   WHERE D.File_ID = @Ac_File_ID;

 END; -- End Of Procedure DCKT_RETRIEVE_S20

GO
