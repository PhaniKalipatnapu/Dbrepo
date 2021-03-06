/****** Object:  StoredProcedure [dbo].[TADR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TADR_RETRIEVE_S1](
	 @An_MemberMci_IDNO NUMERIC(10) ,
	 @Ai_RowFrom_NUMB   INT = 1,
	 @Ai_RowTo_NUMB     INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : TADR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve address summary for TRIP Address
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/21/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT ADX.Line1_ADDR,
         ADX.Line2_ADDR,
         ADX.City_ADDR,
         ADX.State_ADDR,
         ADX.Zip_ADDR,
         ADX.Country_ADDR,
         ADX.Batch_DATE,
		 ADX.SourceBatch_CODE ,
		 ADX.Batch_NUMB ,
		 ADX.SeqReceipt_NUMB ,
         ADX.RowCount_NUMB
    FROM (SELECT X.Line1_ADDR,
                 X.Line2_ADDR,
                 X.City_ADDR,
                 X.State_ADDR,
                 X.Zip_ADDR,
                 X.Country_ADDR,
                 X.RowCount_NUMB,
                 X.Batch_DATE,
				 X.SourceBatch_CODE ,
				 X.Batch_NUMB ,
				 X.SeqReceipt_NUMB ,
                 X.Row_NUMB
            FROM (SELECT TAD.Line1_ADDR,
                         TAD.Line2_ADDR,
                         TAD.City_ADDR,
                         TAD.State_ADDR,
                         TAD.Zip_ADDR,
                         TAD.Country_ADDR,
                         TAD.Batch_DATE,
						 TAD.SourceBatch_CODE ,
						 TAD.Batch_NUMB ,
						 TAD.SeqReceipt_NUMB ,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY Batch_DATE DESC,
                                                     TAD.SeqReceipt_NUMB DESC
                                                     ) AS Row_NUMB
                    FROM TADR_Y1 TAD
                   WHERE TAD.MemberMci_IDNO = @An_MemberMci_IDNO
                    ) X
           WHERE X.Row_NUMB <= @Ai_RowTo_NUMB) ADX
   WHERE ADX.Row_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY Row_NUMB;
 END


GO
