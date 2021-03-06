/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S11]  

AS

/*
 *     PROCEDURE NAME    : NREF_RETRIEVE_S11
 *     DESCRIPTION       : Used to get the document details.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999';
        
      SELECT N.Notice_ID , 
        UPPER(N.DescriptionNotice_TEXT) AS DescriptionNotice_TEXT
      FROM NREF_Y1 N
      WHERE N.EndValidity_DATE = @Ld_High_DATE
      ORDER BY N.DescriptionNotice_TEXT;

                  
END


GO
