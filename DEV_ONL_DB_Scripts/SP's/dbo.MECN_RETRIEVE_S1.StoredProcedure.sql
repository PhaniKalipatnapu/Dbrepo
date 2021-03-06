/****** Object:  StoredProcedure [dbo].[MECN_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME     : MECN_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Member's Contact details from Member Contacts table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
          @Lc_No_INDC   CHAR(1) = 'N',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.Contact_IDNO,
         Y.TypeContact_CODE,
         Y.First_NAME,
         Y.Last_NAME,
         Y.Middle_NAME,
         Y.Maiden_NAME,
         Y.Line1_ADDR,
         Y.Line2_ADDR,
         Y.City_ADDR,
         Y.State_ADDR,
         Y.Zip_ADDR,
         Y.Country_ADDR,
         Y.Phone_NUMB,
         Y.Update_DTTM,
         Y.WorkerUpdate_ID,
         Y.TransactionEventSeq_NUMB,
         Y.Deceased_INDC,
         ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                    FROM MECN_Y1 c
                   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND C.Contact_IDNO = Y.Contact_IDNO
                     AND C.EndValidity_DATE != @Ld_High_DATE), @Lc_No_INDC) AS History_INDC,
         Y.RowCount_NUMB
    FROM (SELECT X.TypeContact_CODE,
                 X.Contact_IDNO,
                 X.First_NAME,
                 X.Middle_NAME,
                 X.Last_NAME,
                 X.Maiden_NAME,
                 X.Phone_NUMB,
                 X.Line1_ADDR,
                 X.Line2_ADDR,
                 X.City_ADDR,
                 X.State_ADDR,
                 X.Zip_ADDR,
                 X.Country_ADDR,
                 X.Deceased_INDC,
                 X.WorkerUpdate_ID,
                 X.Update_DTTM,
                 X.TransactionEventSeq_NUMB,
                 X.ORD_ROWNUM AS rnum,
                 X.RowCount_NUMB
            FROM (SELECT M.TypeContact_CODE,
                         M.Contact_IDNO,
                         M.First_NAME,
                         M.Middle_NAME,
                         M.Last_NAME,
                         M.Maiden_NAME,
                         M.Phone_NUMB,
                         M.Line1_ADDR,
                         M.Line2_ADDR,
                         M.City_ADDR,
                         M.State_ADDR,
                         M.Zip_ADDR,
                         M.Country_ADDR,
                         M.Deceased_INDC,
                         M.WorkerUpdate_ID,
                         M.Update_DTTM,
                         M.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY M.TransactionEventSeq_NUMB DESC ) AS ORD_ROWNUM
                    FROM MECN_Y1 M
                   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND M.EndValidity_DATE = @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnum >= @Ai_RowFrom_NUMB
   ORDER BY RNUM;
 END; -- END of MECN_RETRIEVE_S1


GO
