/****** Object:  StoredProcedure [dbo].[MSSN_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_RETRIEVE_S7] (
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ac_TypePrimary_CODE CHAR(1),
 @Ac_Enumeration_CODE CHAR(1),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the record count from Member SSN table for Unique Number Assigned by the System to the Member, Primary Type Code and Verification Code Received for SSN Verification equal to CONFIRMED GOOD (Y).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE            DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM MSSN_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.TypePrimary_CODE = ISNULL(@Ac_TypePrimary_CODE,M.TypePrimary_CODE)
     AND M.Enumeration_CODE = @Ac_Enumeration_CODE
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of MSSN_RETRIEVE_S7


GO
