/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S46]  (
     @An_Case_IDNO		 NUMERIC(6,0),
     @Ac_Exists_INDC     CHAR(1)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : SORD_RETRIEVE_S46
 *     DESCRIPTION       : This SP check whether History record exist for the given case_IDNO.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11/10/2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1.0
 */

   BEGIN

  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y', 
          @Ld_High_DATE DATE    = '12/31/9999',
          @Lc_No_INDC  CHAR(1)  = 'N';
          
      SET @Ac_Exists_INDC = @Lc_No_INDC;    
        
   SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
     FROM SORD_Y1  a 
     LEFT OUTER JOIN HDCKT_Y1 b 
       ON b.EventGlobalBeginSeq_NUMB = a.EventGlobalBeginSeq_NUMB 
      AND b.File_ID = a.File_ID
    WHERE a.Case_IDNO = @An_Case_IDNO 
      AND a.EndValidity_DATE <> @Ld_High_DATE;
END;--END OF SORD_RETRIEVE_S46


GO
