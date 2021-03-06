/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S8] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S8
  *     DESCRIPTION       : Retrieves distinct State fips code and state name for the given case idno, iv-d out of state fips cod, status code, and the end validity date equal to high date. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusOpen_CODE CHAR(1) = 'O',
          @Ld_High_DATE       DATE = '12/31/9999';

  SELECT DISTINCT b.StateFips_CODE,
         b.State_NAME
    FROM ICAS_Y1 a
         JOIN STAT_Y1 b
          ON a.IVDOutOfStateFips_CODE = b.StateFips_CODE
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Status_CODE = @Lc_StatusOpen_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S8

GO
