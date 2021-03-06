/****** Object:  StoredProcedure [dbo].[CWRK_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CWRK_RETRIEVE_S27] (
 @Ac_Worker_ID   CHAR(30),
 @An_Office_IDNO NUMERIC(3),
 @Ai_Count_QNTY  INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : CWRK_RETRIEVE_S27
 *     DESCRIPTION       : Retrieve the record count for the Case ID in Case details also exist in User Restriction.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10/21/2011
 *     MODIFIED BY       : 
  *    MODIFIED ON       : 
  *    VERSION NO        : 1.0
 */
 BEGIN
  SET @Ai_Count_QNTY = 0;

  DECLARE @Lc_HighProfileYes_INDC CHAR(1) = 'Y',
          @Ld_Current_DATE        DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 CM
   WHERE CM.Case_IDNO IN (SELECT W.Case_IDNO
                            FROM CWRK_Y1 W
                           WHERE W.Worker_ID = @Ac_Worker_ID
                             AND W.Office_IDNO = @An_Office_IDNO
                             AND @Ld_Current_DATE BETWEEN W.Effective_DATE AND W.Expire_DATE
                             AND W.EndValidity_DATE = @Ld_High_DATE)
     AND EXISTS (SELECT 1
                   FROM USRT_Y1 UR
                  WHERE UR.Case_IDNO = CM.Case_IDNO
                    AND UR.MemberMci_IDNO = CM.MemberMci_IDNO
                    AND UR.HighProfile_INDC = @Lc_HighProfileYes_INDC
                    AND UR.EndValidity_DATE = @Ld_High_DATE
                    AND UR.End_DATE > @Ld_Current_DATE);
 END


GO
