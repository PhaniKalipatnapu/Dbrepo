/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S43] (
 @An_MemberMci_IDNO    NUMERIC(10, 0),
 @Ad_Birth_DATE        DATE OUTPUT,
 @Ac_Suffix_NAME       CHAR(4) OUTPUT,
 @Ac_First_NAME        CHAR(16) OUTPUT,
 @Ac_Last_NAME         CHAR(20) OUTPUT,
 @Ac_Middle_NAME       CHAR(20) OUTPUT,
 @Ac_MemberSex_CODE    CHAR(1) OUTPUT,
 @An_MemberSsn_NUMB    NUMERIC(9, 0) OUTPUT,
 @Ac_StatusLocate_CODE CHAR(1) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S43  
  *     DESCRIPTION       : Retrieves Member name,gender and SSN details for a respective Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ad_Birth_DATE = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_StatusLocate_CODE = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_MemberSex_CODE = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_Suffix_NAME = NULL;

  SELECT @Ac_First_NAME = d.First_NAME,
         @Ac_Last_NAME = d.Last_NAME,
         @Ac_Middle_NAME = d.Middle_NAME,
         @Ac_Suffix_NAME = d.Suffix_NAME,
         @Ad_Birth_DATE = d.Birth_DATE,
         @Ac_MemberSex_CODE = d.MemberSex_CODE,
         @Ac_StatusLocate_CODE = l.StatusLocate_CODE,
         @An_MemberSsn_NUMB = d.MemberSsn_NUMB
    FROM DEMO_Y1 d
         JOIN LSTT_Y1 l
          ON d.MemberMci_IDNO = l.MemberMci_IDNO
   WHERE d.MemberMci_IDNO = @An_MemberMci_IDNO
     AND l.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of DEMO_RETRIEVE_S43

GO
