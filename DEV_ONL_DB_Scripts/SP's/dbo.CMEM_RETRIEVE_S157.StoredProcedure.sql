/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S157]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S157]  
(
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_MemberMci_IDNO  NUMERIC(10,0),
     @Ac_Worker_ID		 CHAR(30),
     @Ai_Count_QNTY      INT OUTPUT
)
AS

/*
*     PROCEDURE NAME    : CMEM_RETRIEVE_S157
 *     DESCRIPTION       : Retrieve the Row Count for Case Idno and Member Idno.
  *     DEVELOPED BY     : IMP TEAM
 *     DEVELOPED ON     :  10-17-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_Yes_TEXT  CHAR(1) = 'Y',
          @Ld_Highdate_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 C
    WHERE C.MemberMci_IDNO   =  ISNULL(@An_MemberMci_IDNO, C.MemberMci_IDNO )
      AND C.Case_IDNO        =  ISNULL(@An_Case_IDNO,C.Case_IDNO)
      AND NOT EXISTS(
			SELECT 1
			FROM USRT_Y1 U
			WHERE C.MemberMci_IDNO = U.MemberMci_IDNO
			AND C.Case_IDNO = U.Case_IDNO
			AND U.Familial_INDC = @Lc_Yes_TEXT
			AND U.Worker_ID = @Ac_Worker_ID
            AND U.End_DATE = @Ld_Highdate_DATE
            AND U.EndValidity_DATE = @Ld_Highdate_DATE);
 END


GO
