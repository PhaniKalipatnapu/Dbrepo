/****** Object:  StoredProcedure [dbo].[APDM_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDM_RETRIEVE_S39](
 @An_Application_IDNO NUMERIC(15, 0),
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : APDM_RETRIEVE_S39
  *     DESCRIPTION       : Retrieve the record count for an Application ID and Member ID when Member SSN is empty.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 22-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Li_Zero_NUMB SMALLINT =0,
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APDM_Y1 A
   WHERE A.Application_IDNO = @An_Application_IDNO
     AND A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE
     AND A.MemberSsn_NUMB != @Li_Zero_NUMB;
 END; -- End Of APDM_RETRIEVE_S39


GO
