/****** Object:  StoredProcedure [dbo].[RO157_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_RETRIEVE_S9]  
 (  
   @Ad_BeginFiscal_DATE		DATE,  
   @Ad_EndFiscal_DATE		DATE,  
   @Ac_Worker_ID			CHAR(30),
   @An_TotLine30_QNTY		NUMERIC(11,2),
   @An_TotLine31_QNTY		NUMERIC(11,2),
   @An_TotLine32_QNTY		NUMERIC(11,2),
   @Ac_Exists_INDC			CHAR(1) OUTPUT  
 )     
AS    
  /*    
 *     PROCEDURE NAME    : RO157_RETRIEVE_S9     
 *     DESCRIPTION       : Checking Concurrency for the Update Staff Data Entry.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 07-MAY-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
 BEGIN   
    SET @Ac_Exists_INDC = 'N';  
   DECLARE   
     @Lc_Yes_INDC  CHAR(1) = 'Y',  
     @Lc_LineNo30_TEXT CHAR(2) = '30',  
     @Lc_LineNo31_TEXT CHAR(2) = '31',  
     @Lc_LineNo32_TEXT CHAR(2) = '32';  
   
    SELECT @Ac_Exists_INDC = @Lc_Yes_INDC  
   FROM RO157_Y1 O  
  WHERE EXISTS (  
     SELECT 1  
       FROM RO157_Y1 R  
      WHERE R.BeginFiscal_DATE = @Ad_BeginFiscal_DATE  
        AND R.EndFiscal_DATE   = @Ad_EndFiscal_DATE  
        AND R.LineNo_TEXT = @Lc_LineNo30_TEXT
        AND R.Tot_QNTY = @An_TotLine30_QNTY
        AND R.Worker_ID =@Ac_Worker_ID )  
    AND EXISTS (  
     SELECT 1  
       FROM RO157_Y1 A  
      WHERE A.BeginFiscal_DATE = @Ad_BeginFiscal_DATE  
        AND A.EndFiscal_DATE = @Ad_EndFiscal_DATE  
        AND A.LineNo_TEXT = @Lc_LineNo31_TEXT
        AND A.Tot_QNTY = @An_TotLine31_QNTY
        AND A.Worker_ID =@Ac_Worker_ID)  
    AND EXISTS (  
     SELECT 1  
       FROM RO157_Y1 B  
      WHERE B.BeginFiscal_DATE = @Ad_BeginFiscal_DATE  
        AND B.EndFiscal_DATE = @Ad_EndFiscal_DATE  
        AND B.LineNo_TEXT = @Lc_LineNo32_TEXT
        AND B.Tot_QNTY = @An_TotLine32_QNTY
        AND B.Worker_ID =@Ac_Worker_ID);  
                     
 END; --- End of RO157_RETRIEVE_S9 

GO
