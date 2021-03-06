/****** Object:  StoredProcedure [dbo].[DMNR_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_UPDATE_S2] (
 @An_Case_IDNO          NUMERIC(6, 0),
 @An_OrderSeq_NUMB      NUMERIC(2, 0),
 @An_MajorIntSeq_NUMB   NUMERIC(5, 0),
 @An_MinorIntSeq_NUMB   NUMERIC(5, 0),
 @Ac_ActivityMinor_CODE CHAR(5),
 @An_Topic_IDNO         NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DMNR_UPDATE_S2
  *     DESCRIPTION       : Update the Alert Date for a given Case  and  Minor Activity   
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE DMNR_Y1
     SET AlertPrior_DATE = @Ld_High_DATE
   WHERE Case_IDNO = @An_Case_IDNO
     AND OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
     AND MinorIntSeq_NUMB = @An_MinorIntSeq_NUMB
     AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND Topic_IDNO = @An_Topic_IDNO;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF DMNR_UPDATE_S2 


GO
