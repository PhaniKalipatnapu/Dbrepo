/****** Object:  StoredProcedure [dbo].[RECP_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RECP_RETRIEVE_S2] (
 @Ac_CheckRecipient_CODE	CHAR(1),
 @Ac_CheckRecipient_ID		CHAR(10),
 @Ai_RowFrom_NUMB       	INT = 1,
 @Ai_RowTo_NUMB         	INT = 10        
 )          
AS
 /*
  *     PROCEDURE NAME    : RECP_RETRIEVE_S2
  *     DESCRIPTION       : The recoupment percent/amount history for the Funds Recipient displays in the history pop up which will open on click on the instruction group.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 30-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
    DECLARE @Ld_High_DATE	DATE = '12/31/9999';
        
      SELECT Recoupment_PCT , 
             EndValidity_DATE, 
      		 CpResponse_INDC,
      		 Worker_ID, 
             DescriptionNote_TEXT , 
             RowCount_NUMB 
      FROM (
            SELECT X.Recoupment_PCT, 
                   X.EndValidity_DATE, 
                   X.CpResponse_INDC, 
                   X.Worker_ID, 
                   X.DescriptionNote_TEXT, 
                   X.ORD_ROWNUM , 
                   X.RowCount_NUMB
            FROM (
                 SELECT a.Recoupment_PCT , 
                        a.EndValidity_DATE , 
                        a.CpResponse_INDC , 
                        b.Worker_ID , 
                        c.DescriptionNote_TEXT , 
                        COUNT(1) OVER() AS RowCount_NUMB, 
                        ROW_NUMBER() OVER(ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                  FROM RECP_Y1 a 
                  	JOIN GLEV_Y1 b
                  	   ON a.EventGlobalBeginSeq_NUMB = b.EventGlobalSeq_NUMB 
                  	JOIN UNOT_Y1 c
                  	   ON a.EventGlobalBeginSeq_NUMB = c.EventGlobalSeq_NUMB 
                  WHERE a.CheckRecipient_ID = @Ac_CheckRecipient_ID 
                    AND a.CheckRecipient_CODE = @Ac_CheckRecipient_CODE 
                    AND a.EndValidity_DATE !=  @Ld_High_DATE
               )   X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )   Y
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
ORDER BY ORD_ROWNUM;

END; --END OF RECP_RETRIEVE_S2


GO
