/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S22] (  
     @An_Case_IDNO			NUMERIC(6,0),
     @Ac_FileOld_ID			CHAR(10),
     @Ac_Exists_INDC		CHAR(1) OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S22
 *     DESCRIPTION       : Checking whether given Case_ID and File_ID combination exists in Supprot Order table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE @Ld_High_DATE 	DATE	= '12/31/9999',
			@Lc_No_TEXT		CHAR(1)	= 'N',
		  	@Lc_Yes_TEXT	CHAR(1)	= 'Y';

	SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
     SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
       FROM SORD_Y1 S
      WHERE S.File_ID = @Ac_FileOld_ID 
        AND S.Case_IDNO = @An_Case_IDNO 
        AND S.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF SORD_RETRIEVE_S22


GO
