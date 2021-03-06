/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S1](
		 @An_MemberMci_IDNO NUMERIC(10, 0),
		 @Ac_Status_CODE    CHAR(1) = NULL,
		 @Ai_RowFrom_NUMB   INT = 1,
		 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Address Value, Address Type Code Status Date,
                            Status Code, Begin Date and End Date with Transaction Event Sequence Number for a Member Idno and Status Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/23/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';
  DECLARE @Lc_Trip_TypeAddress_CODE CHAR(1) ='T';

  SELECT ADX.TypeAddress_CODE,
         ADX.Line1_ADDR,
         ADX.Line2_ADDR,
         ADX.City_ADDR,
         ADX.State_ADDR,
         ADX.Zip_ADDR,
         ADX.Country_ADDR,
         ADX.Status_CODE,
         ADX.Status_DATE,
         ADX.Begin_DATE,
         ADX.End_DATE,
         ADX.TransactionEventSeq_NUMB,
         ADX.RowCount_NUMB
    FROM (SELECT X.TypeAddress_CODE,
                 X.Line1_ADDR,
                 X.Line2_ADDR,
                 X.City_ADDR,
                 X.State_ADDR,
                 X.Zip_ADDR,
                 X.Country_ADDR,
                 X.Status_CODE,
                 X.Status_DATE,
                 X.Begin_DATE,
                 X.End_DATE,
                 X.TransactionEventSeq_NUMB,
                 X.RowCount_NUMB,
                 X.Row_NUMB
            FROM (SELECT AD.TypeAddress_CODE,
                         AD.Line1_ADDR,
                         AD.Line2_ADDR,
                         AD.City_ADDR,
                         AD.State_ADDR,
                         AD.Zip_ADDR,
                         AD.Country_ADDR,
                         AD.Status_CODE,
                         AD.Status_DATE,
                         AD.Begin_DATE,
                         AD.End_DATE,
                         AD.TransactionEventSeq_NUMB,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY AD.TypeAddress_CODE ASC,
													CASE AD.End_DATE 
													   WHEN @Ld_High_DATE THEN 1 
													   ELSE 2 
													 END, AD.Begin_DATE DESC,
													AD.Update_DTTM DESC) AS Row_NUMB
                    FROM AHIS_Y1 AD
                   WHERE AD.MemberMci_IDNO = @An_MemberMci_IDNO
                     AND AD.TypeAddress_CODE != @Lc_Trip_TypeAddress_CODE
                     AND AD.Status_CODE = ISNULL(@Ac_Status_CODE, AD.Status_CODE)) X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) ADX
   WHERE ADX.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END

GO
