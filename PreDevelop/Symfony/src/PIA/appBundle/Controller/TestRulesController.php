<?php

namespace PIA\appBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\JsonResponse;

class TestRulesController extends Controller {

    public function indexAction($jobid) {

        $job = $this->getDoctrine()->getRepository('PIABundle:Jobs')
                ->find($jobid);

        return $this->render('PIABundle:TestRules:index.html.twig', array(
                    'job' => $job
        ));
    }

    public function groupsAction($levelid) {

        $repository = $this->getDoctrine()->getRepository('PIABundle:JobGroups');

        $query = $repository->createQueryBuilder('g')
                ->addSelect('r')
                ->addSelect('l')
                ->addSelect('rc')
                ->join('g.rules', 'r')
                ->leftJoin('r.link', 'l')
                ->leftJoin('r.record', 'rc')
                ->where('g.jobLevel = :id')
                ->setParameter('id', $levelid)
                ->getQuery();
        $groups = $query->getArrayResult();

        return new JsonResponse(array('groups' => $groups));
    }

}
