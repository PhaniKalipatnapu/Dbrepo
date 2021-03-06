/****** Object:  StoredProcedure [dbo].[MECN_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_RETRIEVE_S2] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Contact_IDNO   NUMERIC(9, 0),
 @Ai_RowFrom_NUMB   INT = 1,
 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : MECN_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Member's Contact History details from Member Contacts table for Unique Number Assigned by the System to the Member and ID of the Contact.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT Y.TypeContact_CODE,
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
         Y.Deceased_INDC,
         Y.RowCount_NUMB
    FROM (SELECT X.TypeContact_CODE,
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
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS rnum
            FROM (SELECT M.TypeContact_CODE,
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
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY M.TransactionEventSeq_NUMB DESC ) AS ORD_ROWNUM
                    FROM MECN_Y1 M
                   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND M.Contact_IDNO = @An_Contact_IDNO
                     AND M.EndValidity_DATE != @Ld_High_DATE) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.rnum >= @Ai_RowFrom_NUMB
   ORDER BY RNUM;
 END; --END of  MECN_RETRIEVE_S2


GO
