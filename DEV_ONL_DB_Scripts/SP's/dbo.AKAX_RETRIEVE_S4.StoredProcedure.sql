/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S4] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Sequence_NUMB  NUMERIC(11, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_RETRIEVE_S4
  *     DESCRIPTION       : Retrieve the Maximum sequence number from Member Alias Names table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_Sequence_NUMB = 0;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Sequence_NUMB = ISNULL(MAX(A.Sequence_NUMB), 0)
    FROM AKAX_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of AKAX_RETRIEVE_S4


GO
