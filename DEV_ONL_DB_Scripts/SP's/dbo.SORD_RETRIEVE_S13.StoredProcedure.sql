/****** Object:  StoredProcedure [dbo].[SORD_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SORD_RETRIEVE_S13] (
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : SORD_RETRIEVE_S13
  *     DESCRIPTION       : Retrieves the File ID for the respective Case member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE 
	@Lc_Empty_TEXT	CHAR(1)= '',
	@Ld_High_DATE	DATE = '12/31/9999';
	
  SELECT DISTINCT S.File_ID
    FROM SORD_Y1 S
         JOIN CMEM_Y1 C
          ON C.Case_IDNO = S.Case_IDNO
   WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO
     AND S.EndValidity_DATE = @Ld_High_DATE
	 AND LTRIM(RTRIM(S.File_ID)) != @Lc_Empty_TEXT;
 END; -- End Of SORD_RETRIEVE_S13

GO
