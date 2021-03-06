/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S136]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S136] (
 @An_MemberMci_IDNO     NUMERIC(10, 0),
 @Ac_Exists_INDC		CHAR(1)  OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S136
  *     DESCRIPTION       : Retrieves 'YES' when given member mci has Home phone or cell phone number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 18-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_Exists_INDC = 'N';

	DECLARE 
		@Li_Zero_NUMB SMALLINT = 0;


  SELECT @Ac_Exists_INDC = 'Y'
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO
   AND D.MemberSsn_NUMB <> @Li_Zero_NUMB;
   
 END; -- END of DEMO_RETRIEVE_S136

GO
