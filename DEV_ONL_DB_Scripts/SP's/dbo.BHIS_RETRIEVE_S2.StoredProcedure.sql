/****** Object:  StoredProcedure [dbo].[BHIS_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BHIS_RETRIEVE_S2] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @Ad_Statement_DATE	DATE,
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : BHIS_RETRIEVE_S2
  *     DESCRIPTION       : This procedure is used to view current and historical quarterly payment coupons by Case ID.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN

 DECLARE
 	@Li_Zero_NUMB	SMALLINT = 0;
   
 	SELECT X.BeginBill_DATE,
		   X.EndBill_DATE,
		   X.Statement_DATE,  
           X.CurrentSupport_AMNT,
           X.ExpectToPay_AMNT,
           X.Arrears_AMNT,         
           X.EventGlobalSeq_NUMB,
           X.Request_INDC,
           RowCount_NUMB
    FROM (SELECT X.Request_INDC,
                 X.Statement_DATE,
                 X.CurrentSupport_AMNT,
                 X.ExpectToPay_AMNT,
                 X.Arrears_AMNT,
                 X.BeginBill_DATE,
                 X.EndBill_DATE,
                 X.EventGlobalSeq_NUMB,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT a.Request_INDC,
                         a.Statement_DATE,
                         a.CurrentSupport_AMNT,
                         a.ExpectToPay_AMNT,
                         a.Arrears_AMNT,
                         a.BeginBill_DATE,
                         a.EndBill_DATE,
                         a.EventGlobalSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY a.Statement_DATE DESC, a.EventGlobalSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM BHIS_Y1 a
                   WHERE a.Case_IDNO = @An_Case_IDNO
                     AND ((@Ad_Statement_DATE IS NULL)
                           OR (a.Statement_DATE >= @Ad_Statement_DATE))) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB 
           	  OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
           ) X
   WHERE X.row_num >= @Ai_RowFrom_NUMB 
   	  OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
   ORDER BY ROW_NUM;
 END; --END OF BHIS_RETRIEVE_S2  
                                     

GO
