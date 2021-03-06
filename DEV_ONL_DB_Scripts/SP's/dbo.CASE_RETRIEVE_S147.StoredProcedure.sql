/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S147]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S147]
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Exists_INDC CHAR(1) OUTPUT
AS
 /*
  *     PROCEDURE NAME    : CASE_RETRIEVE_S147
  *     DESCRIPTION       : Retrieve Row Count for a Case ID, Case Status is Open and Case Type is NON IV-D.
  *     DEVELOPED BY      : IMP TEAM 
  *     DEVELOPED ON      : 29-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE CHAR(1) = 'O',
          @Lc_TypeNonIvd_CODE     CHAR(1) = 'H',
          @Lc_Yes_INDC            CHAR(1) = 'Y',
          @Lc_No_INDC             CHAR(1) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM CASE_Y1 C
   WHERE C.Case_IDNO = @An_Case_IDNO
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND C.TypeCase_CODE = @Lc_TypeNonIvd_CODE;
 END --End of CASE_RETRIEVE_S147

GO
