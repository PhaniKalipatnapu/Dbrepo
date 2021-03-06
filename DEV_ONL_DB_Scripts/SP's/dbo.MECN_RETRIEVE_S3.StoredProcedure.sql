/****** Object:  StoredProcedure [dbo].[MECN_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MECN_RETRIEVE_S3] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @An_Contact_IDNO   NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : MECN_RETRIEVE_S3
  *     DESCRIPTION       : Retrieve the maximum of ID of the Contact from Member Contacts table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_Contact_IDNO = 0;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_Contact_IDNO = ISNULL(MAX(M.Contact_IDNO), 0)
    FROM MECN_Y1 M
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of MECN_RETRIEVE_S3


GO
