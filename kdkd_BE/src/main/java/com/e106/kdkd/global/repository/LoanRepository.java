package com.e106.kdkd.global.repository;

import com.e106.kdkd.global.common.entity.Loan;
import com.e106.kdkd.global.common.entity.ParentRelation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LoanRepository extends JpaRepository<Loan, String> {

    boolean existsByRelation(ParentRelation parentRelation);

    Loan findByRelation(ParentRelation parentRelation);
}
